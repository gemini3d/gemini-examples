#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Aug 25 13:12:56 2024

@author: zettergm
"""

import typing as T
import numpy as np
from numpy import tanh
import scipy

from neprofile import readprofile
import gemini3d.read
import gemini3d.write

def perturb(cfg: T.Dict[str, T.Any], xg: T.Dict[str, T.Any]):
    # Data from HF systems
    filename="fp_profile.txt"
    z,ne = readprofile(filename)
    ne=ne*1.4
    
    # WARNING total hack; scale up the profile to compensate for decay during
    #   the "settling"/staging simulation
    #ne = 1.4 * ne
    
    # need to do something about out-of-bounds altitudes
    zmin=z.min()
    zmax=z.max()
    zgridmin=xg["alt"].min()
    zgridmax=xg["alt"].max()
    lsample=512
    zdatasample=np.linspace(zgridmin,zgridmax,lsample)
    i=0
    nedatasample=np.zeros(zdatasample.shape)
    while zdatasample[i]<zmin:
        nedatasample[i]=1e-20
        i+=1
    imin=i
    while i<lsample and zdatasample[i]<zmax:
        i+=1
    imax=i
    nedatasample[imin:imax]= scipy.interp(zdatasample[imin:imax],z,ne[:])
       
    for i in range(imax,lsample):
        ne3=nedatasample[i-3]
        ne2=nedatasample[i-2]
        nedatasample[i]=nedatasample[i-1]*ne2/ne3
               
    # construct a full initial condition for density of all species from total
    #   plasma density + assumptions
    x1 = xg["x1"][2:-2]
    x2 = xg["x2"][2:-2]
    x3 = xg["x3"][2:-2]
    nsperturb = np.empty((7, x1.size, x2.size, x3.size))
    for i in range(0, x2.size):
        for j in range(0, x3.size):
            nsperturb[6, :, i, j] = scipy.interp(xg["alt"][:,i,j],zdatasample,nedatasample[:])

    # apply some assumed composition (doesn't matter much unless chemistry is used)
    comp = 1 / 2 + 1 / 2 * tanh((x1 - 200e3) / 15e3)            
    for i in range(0, x2.size):
        for j in range(0, x3.size):            
            nmolec = (1 - comp) * nsperturb[6, :, i, j]
            natomic = comp * nsperturb[6, :, i, j]
            nsperturb[0, :, i, j] = 0.98 * natomic
            nsperturb[4, :, i, j] = 0.01 * natomic
            nsperturb[5, :, i, j] = 0.01 * natomic
            nsperturb[1, :, i, j] = 1 / 3 * nmolec
            nsperturb[2, :, i, j] = 1 / 3 * nmolec
            nsperturb[3, :, i, j] = 1 / 3 * nmolec

    # enforce nonzero min density
    nsperturb = np.maximum(nsperturb, 1e4)
    nsperturb[6, :, :, :] = np.sum(nsperturb[0:5, :, :, :], axis=0)
    
    ###########################################################################
    # Write in a format GEMINI can handle
    ###########################################################################
    # read in original reference data; we will retain flows and temperatures
    dat = gemini3d.read.frame(cfg["indat_file"], var=["ns", "Ts", "vs1"])
    
    gemini3d.write.state(
    cfg["indat_file"],
    dat,
    ns=nsperturb
    )    
