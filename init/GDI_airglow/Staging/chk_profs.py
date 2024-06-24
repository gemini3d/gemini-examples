#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 24 15:42:51 2024

@author: zettergm
"""

import matplotlib.pyplot as plt
import gemini3d.read

direc="~/simulations/sdcard/GDI_airglow_staging_rot_profile/"
cfg=gemini3d.read.config(direc)
xg=gemini3d.read.grid(direc)
alt=xg["x1"][2:-2]

dat1=gemini3d.read.frame(direc,cfg["time"][0])
datend=gemini3d.read.frame(direc,cfg["time"][-1])

neprof1=dat1["ne"][:,10,10]
neprofend=datend["ne"][:,10,10]

plt.semilogx(neprof1,alt)
plt.semilogx(neprofend,alt)