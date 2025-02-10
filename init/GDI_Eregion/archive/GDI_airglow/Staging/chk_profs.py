#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jun 24 15:42:51 2024

@author: zettergm
"""

import matplotlib.pyplot as plt
import gemini3d.read
import numpy as np

direc="~/simulations/ssd/simulations_GDI_airglow/v5/GDI_airglow_staging_rot_profile_offset/"
cfg=gemini3d.read.config(direc)
xg=gemini3d.read.grid(direc)
alt=xg["x1"][2:-2]

direcnoE="~/simulations/ssd/simulations_GDI_airglow/v3/GDI_airglow_staging_rot_offset/"

dat1=gemini3d.read.frame(direc,cfg["time"][0])
datend=gemini3d.read.frame(direc,cfg["time"][-1])
datnoE=gemini3d.read.frame(direcnoE,cfg["time"][-1])

ne=dat1["ne"]
ind = np.argmax(np.array(ne))
i1,i2,i3=np.unravel_index(ind,ne.shape)
neprof1=dat1["ne"][:,i2,i3]
neprofend=datend["ne"][:,i2,i3]

ne=datnoE["ne"]
ind = np.argmax(np.array(ne))
i1,i2,i3=np.unravel_index(ind,ne.shape)
nenoE=datnoE["ne"][:,i2,i3]

plt.semilogx(neprof1,alt/1e3)
plt.semilogx(neprofend,alt/1e3)
plt.semilogx(nenoE,alt/1e3)
plt.ylim(50,700)
plt.xlabel("$n_e (m^{-3})$")
plt.ylabel("alt. (km)")
plt.legend(("staging input","staging output","output sans precipitation"))
plt.show()
