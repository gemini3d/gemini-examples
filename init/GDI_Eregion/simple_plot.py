#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb 10 14:54:05 2025

@author: zettergm
"""

import gemini3d.read
import matplotlib.pyplot as plt
import numpy as np

outdir="~/simulations/sdcard/GDI_round/"

cfg=gemini3d.read.config(outdir)
xg=gemini3d.read.grid(outdir)
dat=gemini3d.read.frame(outdir,time=cfg["time"][-1])     # e.g., reads frame 20

x=xg["x2"][2:-2]    # remove ghost cells for convenience
y=xg["x3"][2:-2]
z=xg["x1"][2:-2]
iz=np.argmin(abs(z-300e3))
ne=dat["ne"]

plt.figure(dpi=150)
plt.pcolormesh(x/1e3,y/1e3,ne[iz,:,:].transpose())
plt.xlabel("x dist. (km)")
plt.ylabel("y dist. (km)")
plt.colorbar()
#plt.ylabel(cb,"$n_e (m^{-3})$")
plt.title("Sample GDI output Frame")
