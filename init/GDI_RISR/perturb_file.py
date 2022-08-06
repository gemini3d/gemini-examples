#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Aug  5 20:15:32 2022

@author: zettergm
"""

import typing as T
import numpy as np
import numpy.random

import gemini3d.read
import gemini3d.write
from numpy import tanh
import h5py

def perturb_file(cfg: T.Dict[str, T.Any], xg: T.Dict[str, T.Any]):
    # coordinates
    x1 = xg["x1"][2:-2]
    x2 = xg["x2"][2:-2]
    x3 = xg["x3"][2:-2]    
    
    # read in electron density data
    h5f=h5py.File("/Users/zettergm/simulations/RISR_staging/inputs/nexyz.h5","r")
    neRISR=h5f["Ne"][:]
    h5f.close()
        
    # distribute to various ions?
    nsperturb=np.empty((7,x1.size,x2.size,x3.size))
    nsperturb[6,:,:,:]=neRISR
    comp=1/2+1/2*tanh((x1-200e3)/15e3)
    for i in range(0,x2.size):
        for j in range(0,x3.size):
            nmolec=(1-comp)*neRISR[:,i,j]
            natomic=comp*neRISR[:,i,j]
            nsperturb[0,:,i,j]=0.98*natomic
            nsperturb[4,:,i,j]=0.01*natomic
            nsperturb[5,:,i,j]=0.01*natomic
            nsperturb[1,:,i,j]=1/3*nmolec
            nsperturb[2,:,i,j]=1/3*nmolec
            nsperturb[3,:,i,j]=1/3*nmolec        
    
    # enforce nonzero min density
    nsperturb = np.maximum(nsperturb, 1e4)
    
    # read in original reference data; we will retain flows and temperatures
    dat = gemini3d.read.data(cfg["indat_file"], var=["ns", "Ts", "vs1"])
    
    gemini3d.write.state(
    cfg["indat_file"],
    dat,
    ns=nsperturb
    )
    