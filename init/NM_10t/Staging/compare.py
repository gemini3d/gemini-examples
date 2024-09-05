#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Aug 25 13:24:46 2024

@author: zettergm
"""

from neprofile import readprofile
import matplotlib.pyplot as plt
import gemini3d.read

filename="fp_profile.txt"
z,ne = readprofile(filename)

 # plot
plt.figure(dpi=100)
plt.semilogx(ne,z/1e3)
plt.xlabel("$n_e$ ($m^{-3}$)")
plt.ylabel("z (km)")

# check eq directory
direc="~/simulations/sdcard/NM_10t_May_eq2/"
cfg=gemini3d.read.config(direc)
xg=gemini3d.read.grid(direc)
dat=gemini3d.read.frame(direc,cfg["time"][-1])

modelz=xg["alt"][:,xg["lx"][1]//2,xg["lx"][2]//2]
modelne=dat["ne"][:,xg["lx"][1]//2,xg["lx"][2]//2]
plt.semilogx(modelne,modelz/1e3)
plt.legend(("HF data","GEMINI Equil. sim."))
plt.ylim((0,600))
plt.xlim((1e8,3e12))
