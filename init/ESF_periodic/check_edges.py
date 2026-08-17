#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Aug 15 21:23:58 2026

@author: zettergm
"""
import gemini3d.read
import matplotlib.pyplot as plt
import numpy as np

direc = "~/simulations/sdcard/simulations_ESF/Gaussian/ESF_periodic_ground_HWM/ESF_gaussian_ground/"
cfg = gemini3d.read.config(direc)
xg = gemini3d.read.grid(direc)
dat = gemini3d.read.frame(direc+"/20160303_19500.000000.h5")

n=dat["ns"][0,xg["lx"][0]//2,:,:]

# Density artifact at boundary
plt.figure()
plt.pcolormesh(np.log10(n),shading="interp")
plt.colorbar()
plt.clim((0,12))

# Can see the boundary potential perturbations here that are causing the weirdness in plasma density
plt.figure()
plt.pcolormesh(dat["Phitop"],shading="interp")
plt.colorbar()
plt.clim((-1,1))