#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct  2 12:49:16 2025

Test generation of curl-free, specified electric field

@author: zettergm
"""

import numpy as np
import matplotlib.pyplot as plt

pk=50e-3

l2=256
l3=128
x2=np.linspace(-1000e3,1000e3,l2)
x3=np.linspace(-100e3,100e3,l3)
X2,X3 = np.meshgrid(x2,x3,indexing="ij")

meanx2=x2.mean()
meanx3=x3.mean()
sigx2=1/20*(x2.max()-x2.min())
sigx3=1/20*(x3.max()-x3.min())
displace = 3 * sigx3

x3ctr = meanx2 + displace * np.tanh((X2 -meanx2) / (2 * sigx2))


Ey =  -( pk * np.exp(-((X2 - meanx2) ** 2) / 2 / sigx2**2) * 
         np.exp(-((X3 - x3ctr + 1.5 * sigx3) ** 2) / 2 / sigx3**2) )

Eyx,Eyy = np.gradient(Ey,x2,x3)
Ex=np.zeros((l2,l3))
for i in range(0,l2):
    for j in range (0,l3):
        Ex[i, j]=np.trapz(Eyx[i,0:j+1],x3[0:j+1])

Exx,Exy=np.gradient(Ex,x2,x3)

# Test plots
plt.subplots(3,1,dpi=150)
plt.subplot(3,1,1)
plt.pcolormesh(x2,x3,Ey.transpose(),shading='auto')
plt.colorbar()
plt.title("$E_y$")
plt.show()

plt.subplot(3,1,2)
plt.pcolormesh(x2,x3,Ex.transpose(),shading='auto')
plt.colorbar()
plt.title("$E_x$")
plt.show()

plt.subplot(3,1,3)
plt.pcolormesh(x2,x3,(Eyx-Exy).transpose())
plt.colorbar()
plt.show()
