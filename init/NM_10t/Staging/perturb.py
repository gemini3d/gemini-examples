#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Aug 23 19:10:33 2024

@author: zettergm
"""

import matplotlib.pyplot as plt
import numpy as np

###############################################################################
eps0=8.854e-11
me=9.1e-31
elchrg=1.6e-19
def fp2ne(fp):
    return fp**2*eps0*me/elchrg**2
###############################################################################

###############################################################################
def readprofile(filename):
    file=open(filename,"r")
    
    # header
    for i in range(7):
        _=file.readline()
    # data
    z=np.array([])
    fp=np.array([])
    while True:
        line=file.readline()
        if len(line)==0:
            break
        else:
            z=np.append(z,float(line[0:4])*1000)
            fp=np.append(fp,float(line[4:-1])*1e6)
    # convert to plasma density
    ne=fp2ne(fp)
    return z,ne
###############################################################################


filename="fp_profile.txt"
z,ne = readprofile(filename)

# plot
plt.figure(dpi=100)
plt.semilogx(ne,z/1e3)
plt.xlabel("$n_e$ ($m^{-3}$)")
plt.ylabel("z (km)")

    