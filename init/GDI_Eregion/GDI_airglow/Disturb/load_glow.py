#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jul  3 12:13:43 2024

@author: zettergm
"""

from pathlib import Path
import matplotlib.pyplot as plt
import gemini3d.read

# source simulation
direc="/Users/zettergm/simulations/ssd/simulations_GDI_airglow/v5/GDI_airglow_disturb_rot_profile_offset_glow"

# read in optical intensity from a single output frame
filename=Path(direc+"/aurmaps/20160203_21540.000000.h5")
dataur=gemini3d.read.glow(filename)
I630=dataur["rayleighs"][4]     # index 4 is redline brightness
x=dataur["x2"]
y=dataur["x3"]

plt.figure()
plt.pcolormesh(x,y,I630.transpose())
plt.colorbar()
plt.xlabel("x")
plt.ylabel("y")
plt.show()