#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug  5 13:57:47 2026

@author: zettergm
"""

import gemini3d.read
import matplotlib.pyplot as plt

direc="/Volumes/uSDCard1TB/simulations/simulations_ESF/ESF_gaussian_ground/"
cfg=gemini3d.read.config(direc)
xg=gemini3d.read.grid(direc)

plt.figure()
ilon=xg["lx"][2]//2
plt.scatter(xg["glat"][:,:,ilon],xg["alt"][:,:,ilon])
