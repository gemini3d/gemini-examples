#!/usr/bin/env python3
"""
@author: zettergm
"""

# imports
import gemini3d.read as read
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.pyplot import show
from gemini3d.grid.gridmodeldata import model2magcoords,model2geogcoords
from gemini3d.grid.convert import unitvecs_geographic

# load some sample data (3D)
#direc = "~/simulations/raid/tohoku20113D_lowres_3Dneu_f90/"
direc = "~/simulations/ssd/EISCAT3D_DynaMIT/BingMM/"
cfg = read.config(direc)
xg = read.grid(direc)
parm="J1"
dat = read.frame(direc, cfg["time"][20])

###############################################################################
# this plotting function will internally grid the data into slices and plot them
###############################################################################
# print("Plotting...")
# plotcurv3D(xg, dat[parm], cfg, lalt=128, llon=128, llat=128, coord="geographic")
# show(block=False)

###############################################################################
# produce gridded dataset arrays from model output for user
###############################################################################
lalt=256; llon=128; llat=256;

# regrid data in geographic
print("Sampling in geographic coords...")
galti, gloni, glati, parmgi = model2geogcoords(xg, dat[parm], lalt, llon, llat, wraplon=True)

# regrid in geomagnetic
print("Sampling in geomagnetic coords...")
malti, mloni, mlati, parmmi = model2magcoords(xg, dat[parm], lalt, llon, llat)

# make a simple magnetic plot of the output
plt.figure()
plt.pcolormesh(mlati,malti,parmmi[:,llon//3,:])

# ###############################################################################
# # read in a vector quantity, rotate into geographic components and then grid
# ###############################################################################
# v1=dat["v1"]; v2=dat["v2"]; v3=dat["v3"];
# [egalt,eglon,eglat]=unitvecs_geographic(xg)    
# #^ returns a set of geographic unit vectors on xg; these are in ECEF geomag comps
# #    like all other unit vectors in xg

# # each of the components in models basis projected onto geographic unit vectors
# vgalt=( np.sum(xg["e1"]*egalt,3)*dat["v1"] + np.sum(xg["e2"]*egalt,3)*dat["v2"] + 
#     np.sum(xg["e3"]*egalt,3)*dat["v3"] )
# vglat=( np.sum(xg["e1"]*eglat,3)*dat["v1"] + np.sum(xg["e2"]*eglat,3)*dat["v2"] +
#     np.sum(xg["e3"]*eglat,3)*dat["v3"] )
# vglon=( np.sum(xg["e1"]*eglon,3)*dat["v1"] + np.sum(xg["e2"]*eglon,3)*dat["v2"] + 
#     np.sum(xg["e3"]*eglon,3)*dat["v3"] )

# # must grid each (geographic) vector components separately
# print("Sampling vector compotnents in geographic...")
# galti, gloni, glati, vgalti = model2geogcoords(xg, vgalt, lalt, llon, llat, wraplon=True)
# galti, gloni, glati, vglati = model2geogcoords(xg, vglat, lalt, llon, llat, wraplon=True)
# galti, gloni, glati, vgloni = model2geogcoords(xg, vglon, lalt, llon, llat, wraplon=True)

# # for comparison also grid the flows in the model coordinate system componennts
# galti, gloni, glati, v1i = model2geogcoords(xg, dat["v1"], lalt, llon, llat, wraplon=True)
# galti, gloni, glati, v2i = model2geogcoords(xg, dat["v2"], lalt, llon, llat, wraplon=True)
# galti, gloni, glati, v3i = model2geogcoords(xg, dat["v3"], lalt, llon, llat, wraplon=True)

# # quickly compare flows in model components vs. geographic as a meridional slice
# plt.subplots(1,3)

# plt.subplot(2,3,1)
# plt.pcolormesh(glati,galti,v1i[:,64,:])
# plt.xlabel("glat")
# plt.ylabel("glon")
# plt.title("$v_1$")
# plt.colorbar()

# plt.subplot(2,3,2)
# plt.pcolormesh(glati,galti,v2i[:,64,:])
# plt.xlabel("glat")
# plt.ylabel("glon")
# plt.colorbar()
# plt.title("$v_2$")

# plt.subplot(2,3,3)
# plt.pcolormesh(glati,galti,v3i[:,64,:])
# plt.xlabel("glat")
# plt.ylabel("glon")
# plt.colorbar()
# plt.title("$v_3$")

# plt.subplot(2,3,4)
# plt.pcolormesh(glati,galti,vgalti[:,64,:])
# plt.xlabel("glat")
# plt.ylabel("glon")
# plt.title("$v_r$")
# plt.colorbar()

# plt.subplot(2,3,5)
# plt.pcolormesh(glati,galti,vglati[:,64,:])
# plt.xlabel("glat")
# plt.ylabel("glon")
# plt.colorbar()
# plt.title("$v_{mer}$")

# plt.subplot(2,3,6)
# plt.pcolormesh(glati,galti,vgloni[:,64,:])
# plt.xlabel("glat")
# plt.ylabel("glon")
# plt.colorbar()
# plt.title("$v_{zon}$")
