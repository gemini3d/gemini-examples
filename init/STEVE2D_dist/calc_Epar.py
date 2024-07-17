#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul 17 14:32:28 2024

Because GEMINI2D does not output Eparallel or full potential (i.e. varying along B)
  by default we need to do a few calculations to recover these from the data.  

@author: zettergm
"""

import gemini3d.read
import gemini3d.conductivity
import matplotlib.pyplot as plt
import os
import numpy as np

# tell pygemini where to find msis
os.environ["GEMINI_ROOT"]="/Users/zettergm/Projects/gemini3d/build/msis/"

# read simulations data
direc="~/simulations/sdcard/STEVE2D_dist/"
cfg=gemini3d.read.config(direc)
xg=gemini3d.read.grid(direc)
dat=gemini3d.read.frame(direc,cfg["time"][30])     # use frame 50
y=xg["x3"][2:-2]
z=xg["x1"][2:-2]

# recompute conductivities over grid
sigP, sigH, sig0, SigP, SigH, incap, Incap = (
    gemini3d.conductivity.conductivity_reconstruct(cfg["time"][30], dat, cfg, xg) )

Jz=dat["J1"]    # field-aligned current, positive up
Ez=Jz/sig0

plt.figure(dpi=200)
Ezplot=np.reshape(np.array(Ez), [z.size,y.size])
plt.pcolormesh(y,z,Ezplot,shading="gouraud")
plt.xlabel("y")
plt.ylabel("z")
plt.ylim((50e3, 400e3))
plt.colorbar()
plt.title("$E_\parallel$ (V/m)")