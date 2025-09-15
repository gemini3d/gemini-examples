#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul 17 14:32:28 2024

Because GEMINI2D does not output Eparallel or full potential (i.e. varying along B)
  by default we need to do a few calculations to recover these from the data.  

NOTES:
    - add potential drop calculations
    - add mean free path calculation, total potential drop is irrelevant if all the
        energy is lost soon after acceleration
    - temperature may play a role in mfp, i.e. both in thermal velocity and also in 
        temp.-dependence of collisions (need high energy corrections?)

@author: zettergm
"""

import gemini3d.read
import gemini3d.conductivity
import matplotlib.pyplot as plt
import os
import numpy as np

##############################################################################
# tell pygemini where to find msis
os.environ["GEMINI_ROOT"]="/Users/zettergm/Projects/gemini3d/build/msis/"

# read simulations data
iframe=16
direc="~/simulations/sdcard/STEVE2D_dist_test/"
cfg=gemini3d.read.config(direc)
xg=gemini3d.read.grid(direc)
dat=gemini3d.read.frame(direc,cfg["time"][iframe])     # use frame 50
y=xg["x3"][2:-2]
z=xg["x1"][2:-2]

# recompute conductivities over grid
sigP, sigH, sig0, SigP, SigH, incap, Incap = (
    gemini3d.conductivity.conductivity_reconstruct(cfg["time"][iframe], dat, cfg, xg) )

# have J1, can compute sigma0, so can get E1
Jz=dat["J1"]    # field-aligned current, positive up
Ez=Jz/sig0
##############################################################################

plt.figure(dpi=200)
Ezplot=np.reshape(np.array(Ez), [z.size,y.size])
plt.pcolormesh(y,z,Ezplot,shading="gouraud")
plt.xlabel("y")
plt.ylabel("z")
plt.ylim((50e3, 400e3))
plt.colorbar()
plt.title("$E_\parallel$ (V/m)")

plt.figure(dpi=200)
neplot=np.reshape(np.array(dat["ne"]), [z.size,y.size])
plt.pcolormesh(y,z,np.log10(neplot),shading="gouraud")
plt.xlabel("y")
plt.ylabel("z")
plt.ylim((50e3, 400e3))
plt.clim(4,11.5)
plt.colorbar()
plt.title("$n_e$ (V/m)")

plt.figure(dpi=200)
J1plot=np.reshape(np.array(dat["J1"]), [z.size,y.size])
plt.pcolormesh(y,z,J1plot,shading="gouraud")
plt.xlabel("y")
plt.ylabel("z")
plt.ylim((50e3, 400e3))
plt.colorbar()
plt.title("$J_\parallel$ (V/m)")