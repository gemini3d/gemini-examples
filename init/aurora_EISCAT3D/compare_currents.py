#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct  2 15:08:27 2023

@author: zettergm
"""
import numpy as np
from gemini3d.grid.convert import geomag2geog, geog2geomag
import fac_input_to_matt # the script I sent earlier including the functions to estimate FAC at a given point and time
from gemini3d.grid.gridmodeldata import model2geogcoords, model2pointsgeogcoords, geog2dipole, model2pointsgeomagcoords
import gemini3d.read
import matplotlib.pyplot as plt

'''
Compare GEMINI FAC to the synthetic prescribed FACs
'''

# Load GEMINI data
direc="~/simulations/ssd/aurora_EISCAT3D_test/"
it=1
if (not "cfg" in locals()):
    print("Reloading data...")
    cfg=gemini3d.read.config(direc)
    xg=gemini3d.read.grid(direc)
    dat=gemini3d.read.frame(direc,time=cfg["time"][it])

# Getting the analytic FAC profile
centerlon = 105 # the longitudinal cenrte (in degrees) of SCW structure
width = 90 # longitudinal width in degrees of SCW feature
scaling = 10 # increase the resulting FAC magnitudes, since the fitted values are too small (AMPERE does not capture small scale stuff)

lt=len(cfg["time"])
timesec=np.empty(lt)
timeref=cfg["time"][0]
for it in range(0,lt):
    dt=cfg["time"][it]-timeref
    timesec[it]=dt.total_seconds()
_times=timesec/60.0
#_times = np.ones(1)*1 #temporal locations to evaluare for FAC [minutes]
# _times = np.arange(0,200,100) #temporal locations to evaluare for FAC
_mlats = np.linspace(50, 85, 512) # mlats to evaluate
_mlons = np.linspace(centerlon-width*0.5, centerlon+width*0.5, 32) # mlons to evaluate
shape = (_times.size, _mlats.size, _mlons.size)
times, mlats, mlons = np.meshgrid(_times, _mlats, _mlons, indexing='ij') # make 3D grid of locations
fac = fac_input_to_matt.fac_input(times, mlons, mlats, centerlon=centerlon, width=width, scaling=scaling, sigmat=5, duration=5)

# Getting the FAC from GEMINI
#it=np.argmin((cfg["time"]-cfg["time"][0]).total_seconds()-_times*60.0)
#J1=model2pointsgeomagcoords(xg, dat["J1"], np.ones(mlons[0,:,:].size)*180*1e3, mlons[0,:,:].flatten(), mlats[0,:,:].flatten())
J1=model2pointsgeomagcoords(xg, dat["J1"], np.ones(mlons[0,:,:].size)*3000*1e3, mlons[0,:,:].flatten(), mlats[0,:,:].flatten())

#_glon, _glat = geomag2geog(np.radians(mlons), np.radians(90-mlats)) #returns in degrees
#J1 = model2pointsgeogcoords(xg, dat['J1'], np.ones(_glon.size)*180*1e3, _glon.flatten(), _glat.flatten())


# Ploting a fixed time
plt.figure(dpi=150)
plt.subplots(2,1)
plt.subplot(2,1,1)
plt.pcolormesh(_mlons,_mlats,fac[it,:,:])
plt.colorbar()
plt.xlabel("long")
plt.ylabel("lat")
plt.subplot(2,1,2)
plt.pcolormesh(_mlons,_mlats,J1.reshape(shape[1:3]))
plt.colorbar()
plt.xlabel("long")
plt.ylabel("lat")


# Plotting a single time,long slice
plt.figure(dpi=150)
lonindex = 3
plt.plot(mlats[0,:,lonindex],J1.reshape(shape[1:3])[:,lonindex], label='GEMINI')
plt.plot(mlats[0,:,lonindex],fac.reshape(shape)[it,:,lonindex], label='Analytic expression')
plt.legend()
plt.xlabel('mlat')
plt.ylabel('FAC [A/m2]')
#plt.xlim(62.5,80)
#plt.ylim(-3.6e-7,1e-7)
plt.title('FACs along mlon = %3i' % _mlons[lonindex])


