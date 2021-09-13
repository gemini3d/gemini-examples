#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 13 11:47:40 2021

Create GEMINI precipitation input from FAST data

@author: zettergm
"""

# imports
#import typing as T
import numpy as np
import gemini3d.write as write
from fast import readfast,smoothfast

# global vars
pi=np.pi
filename="/Users/zettergm/Dropbox (Personal)/proposals/UNH_GDC/FASTdata/nightside.txt"

def fast2GEMINI(cfg, xg):
    # output dict.
    pg={}
    
    # read in the data
    [invlat,eflux,chare]=readfast(filename)
    
    # smooth data a bit prior to insertion into model
    lsmooth=3
    [efluxsmooth,charesmooth]=smoothfast(lsmooth,eflux,chare)
    
    # basic grid info
    gridmlat=90-xg["theta"]*180/pi
    gridmlon=xg["phi"]*180/pi
    mlatmin=np.min(gridmlat)
    mlatmax=np.max(gridmlat)
    mlonmin=np.min(gridmlon)
    mlonmax=np.max(gridmlon)
    
    # precipitation input grids
    llon=128
    llat=invlat.size
    pg["mlon"]=np.linspace(mlonmin,mlonmax,llon)
    pg["mlat"]=invlat
    mlonctr=np.average(pg["mlon"])
    mlatctr=np.average(pg["mlat"])
    
    # for convenience recenter grid on what the user has made
    dmlat=np.average(gridmlat)-mlatctr
    pg["mlat"]=pg["mlat"]+dmlat
    
    # time grid for precipitation
    tdur=cfg["tdur"].total_seconds()
    dtprec=cfg["dtprec"].total_seconds()
    t=np.arange(0,tdur+dtprec,dtprec)
    meant=np.average(t)
    lt=t.size
    
    # longitude shape
    pg["Q"]=np.empty( (lt,llon,llat) )
    pg["E0"]=np.empty( (lt,llon,llat) )
    siglon=10
    sigt=250
    for ell in range(0,lt):
        tshape=np.exp(-(t[ell]-meant)**2/2/sigt**2)
        for k in range(0,llon):
            lonshape=np.exp(-(pg["mlon"][k]-mlonctr)**2/2/siglon**2)
            pg["Q"][ell,k,:]=tshape*lonshape*eflux[:]
            pg["E0"][ell,k,:]=tshape*chare[:]
        
    # write these to the simulation input directory
    breakpoint()
    write.precip(pg, cfg["precdir"], cfg["file_format"])
