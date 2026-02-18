#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug  8 09:53:27 2022

@author: zettergm
"""

# Imports
import h5py
import numpy as np
import gemini3d.grid.tilted_dipole
import gemini3d.coord
import scipy.interpolate

# Load GITM GDC simulationsGITM
filename1 = (
    "/Users/zettergm/Dropbox (Personal)/proposals/3DI/GITMdata/GDC_Storm_2200_2230_UT_3DALL.mat"
)
filename2 = "/Users/zettergm/Dropbox (Personal)/proposals/3DI/GITMdata/GDC_Storm_2200_2230_UT_3DALL_iondensities.mat"
h5obj1 = h5py.File(filename1)
datasets1 = h5obj1.keys()
h5obj2 = h5py.File(filename2)
datasets2 = h5obj2.keys()

# Data describing GITM grid
alt = h5obj1["alt_all"][:]
lat = h5obj1["lat_all"][:]
lon = h5obj1["lon_all"][:]
lat = lat[1, :, 1, 1]
alt = alt[:, 1, 1, 1]
lon = lon[1, 1, :, 1]
# [theta,phi]=gemini3d.coord.geog2geomag(lat, lon)
# mlon=np.rad2deg(phi)
# mlat=90-np.rad2deg(theta)

###############################################################################
# As a matter of convenience we reorganize the GITM data in the same manner as
#   GEMINI data are organized.
###############################################################################
# Array of GITM ion densities
print("...  Reading GITM data ...")
ns = np.empty((alt.size, lat.size, lon.size, 7))
permorder = (0, 1, 2)
it = 15
ns[:, :, :, 5] = np.transpose(h5obj2["Hi_all"][:][:, :, :, it], permorder)
ns[:, :, :, 1] = np.transpose(h5obj2["NOi_all"][:][:, :, :, it], permorder)
ns[:, :, :, 2] = np.transpose(h5obj2["N2i_all"][:][:, :, :, it], permorder)
ns[:, :, :, 3] = np.transpose(h5obj2["O2i_all"][:][:, :, :, it], permorder)
ns[:, :, :, 4] = np.transpose(h5obj2["Ni_all"][:][:, :, :, it], permorder)
ns[:, :, :, 0] = (
    np.transpose(h5obj2["Oi_2D_all"][:][:, :, :, it], permorder)
    + np.transpose(h5obj2["Oi_2P_all"][:][:, :, :, it], permorder)
    + np.transpose(h5obj2["Oi_4SP_all"][:][:, :, :, it], permorder)
)
ns[:, :, :, 6] = np.sum(ns[:, :, :, 0:6], axis=3)
h5obj2.close()

# Ion temperatures
Ts = np.empty((alt.size, lat.size, lon.size, 7))
for ispec in range(0, 6):
    Ts[:, :, :, ispec] = np.transpose(h5obj1["Ti_all"][:][:, :, :, it], permorder)
Ts[:, :, :, 6] = np.transpose(h5obj1["Te_all"][:][:, :, :, it], permorder)

# Ion drifts - FIXME: I'm not going to even both projecting these right now we just want a demo...
vs1 = np.empty((alt.size, lat.size, lon.size, 7))
for ispec in range(0, 7):
    vs1[:, :, :, ispec] = np.transpose(h5obj1["ViUp_all"][:][:, :, :, it], permorder)
vs2 = np.empty((alt.size, lat.size, lon.size, 7))
for ispec in range(0, 7):
    vs2 = np.transpose(h5obj1["ViN_all"][:][:, :, :, it], permorder)
vs2 = np.empty((alt.size, lat.size, lon.size, 7))
for ispec in range(0, 7):
    vs3 = np.transpose(h5obj1["ViE_all"][:][:, :, :, it], permorder)
h5obj1.close()

###############################################################################
# Define/compute a region of interest for GEMINI simulation based on a grid that
#   we recompute here for convenience
###############################################################################
print("...  Creating GEMINI mesh ...")
p = {}
p["dtheta"] = 11
p["dphi"] = 19
p["lp"] = 120
p["lq"] = 160
p["lphi"] = 64
p["altmin"] = 80e3
p["glat"] = 78.22
p["glon"] = 15.6
p["gridflag"] = 0
p["iscurv"] = True
xg = gemini3d.grid.tilted_dipole.tilted_dipole3d(p)
lx1 = xg["lx"][0]
lx2 = xg["lx"][1]
lx3 = xg["lx"][2]

# Form a list of glat,glon points (targets for interpolation)
altpoints = xg["alt"].flatten(order="F")
glatpoints = xg["glat"].flatten(order="F")
glonpoints = xg["glon"].flatten(order="F")
# [ALT,LAT,LON]=np.meshgrid(alt,lat,lon, indexing="ij" )
nsin = np.empty((lx1, lx2, lx3, 7))
vs1in = np.empty((lx1, lx2, lx3, 7))
Tsin = np.empty((lx1, lx2, lx3, 7))
print("...  Interpolating denisty arrays to GEMINI mesh ...")
for isp in range(0, 7):
    tmp = scipy.interpolate.interpn(
        points=(alt, lat, lon),
        values=ns[:, :, :, isp],
        xi=(altpoints, glatpoints, glonpoints),
        bounds_error=False,
        fill_value=1e4,
    )
    nsin[:, :, :, isp] = np.reshape(tmp, [lx1, lx2, lx3], order="F")
    tmp = scipy.interpolate.interpn(
        points=(alt, lat, lon),
        values=vs1[:, :, :, isp],
        xi=(altpoints, glatpoints, glonpoints),
        bounds_error=False,
        fill_value=0,
    )
    vs1in[:, :, :, isp] = np.reshape(tmp, [lx1, lx2, lx3], order="F")
    tmp = scipy.interpolate.interpn(
        points=(alt, lat, lon),
        values=Ts[:, :, :, isp],
        xi=(altpoints, glatpoints, glonpoints),
        bounds_error=False,
        fill_value=100,
    )
    Tsin[:, :, :, isp] = np.reshape(tmp, [lx1, lx2, lx3], order="F")


###############################################################################
# Correct density fill values so the simulation doesn't go bonkers
###############################################################################
print("...  Correcting fill values ...")
for isp in range(0, 7):
    for ix3 in range(0, lx3):
        for ix2 in range(0, lx2):
            ix1 = 0
            while xg["alt"][ix1, ix2, ix3] > alt[-4]:
                ix1 += 1
            nref1 = nsin[ix1 - 1, ix2, ix3, isp]
            nref2 = nsin[ix1, ix2, ix3, isp]
            ratio = nref1 / nref2
            ix1 -= 1
            while ix1 >= 0:
                nsin[ix1, ix2, ix3, isp] = min(
                    ratio * nsin[ix1 + 1, ix2, ix3, isp], nsin[ix1 + 1, ix2, ix3, isp]
                )
                ix1 -= 1


###############################################################################
# Visualization and checking
###############################################################################
import matplotlib.pyplot as plt

nein = nsin[:, :, :, 6]
ne = ns[:, :, :, 6]
###############################################################################
plt.subplots(1, 2, dpi=150)
plt.subplot(1, 2, 1)
plt.pcolormesh(nein[140, :, :])
plt.colorbar()
plt.subplot(1, 2, 2)
ialt = np.argmin(abs(alt - 110e3))
plt.pcolormesh(lon, lat, ne[ialt, :, :])
plt.colorbar()
cornerglon = np.array(
    [xg["glon"][140, 0, 0], xg["glon"][140, 0, -1], xg["glon"][140, -1, 0], xg["glon"][140, -1, -1]]
)
cornerglat = np.array(
    [xg["glat"][140, 0, 0], xg["glat"][140, 0, -1], xg["glat"][140, -1, 0], xg["glat"][140, -1, -1]]
)
plt.plot(cornerglon, cornerglat, "wo", markersize=4)
###############################################################################
plt.figure(dpi=150)
plt.pcolormesh(np.log10(nein[:, :, 32]))
plt.colorbar()
