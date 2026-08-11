#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Aug  5 13:29:37 2026

@author: zettergm
"""

import gemini3d.read
import matplotlib.pyplot as plt

direc="/Volumes/uSDCard1TB/simulations/simulations_ESF/VEGA/gemini3d_ESF_gaussian_HWM/ESF_gaussian_ground/"
cfg=gemini3d.read.config(direc)
xg=gemini3d.read.grid(direc)
dat=gemini3d.read.frame(direc,time=cfg["time"][0])

plt.figure()
plt.pcolormesh(dat["Phitop"])
plt.colorbar()