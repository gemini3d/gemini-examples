#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Feb 19 20:16:33 2024

make sure pygemini conductivity functions work properly

@author: zettergm
"""

import gemini3d.conductivity
import matplotlib.pyplot as plt
import gemini3d.read
import os

cfg=gemini3d.read.config("~/simulations/sdcard/KHI_BGfield_nodivJ0_noisy/")
xg=gemini3d.read.grid("~/simulations/sdcard/KHI_BGfield_nodivJ0_noisy/")
dat=gemini3d.read.frame("~/simulations/sdcard/KHI_BGfield_nodivJ0_noisy/",time=cfg["time"][-1])
os.environ["GEMINI_ROOT"]="~/libgem_gnu/bin/"

sigP,sigH,sig0,SigP,SigH,incap,Incap = gemini3d.conductivity.conductivity_reconstruct(
    cfg["time"][-1],dat,cfg,xg)

x=xg["x2"][2:-2]
y=xg["x3"][2:-2]
z=xg["x1"][2:-2]

plt.subplots(1,2,dpi=150)
plt.subplot(1,2,1)
plt.pcolormesh(SigP)
plt.colorbar()
plt.subplot(1,2,2)
plt.pcolormesh(abs(SigH))
plt.colorbar()

plt.figure()
plt.semilogx(sig0[:,1,1],z/1e3)
plt.semilogx(sigP[:,1,1],z/1e3)
plt.semilogx(abs(sigH[:,1,1]),z/1e3)
plt.legend( ("0","P","H") )
