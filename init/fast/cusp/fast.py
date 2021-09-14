#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 13 10:57:06 2021

Tools to deal with text input FAST data

@author: zettergm
"""

# imports
import numpy as np

# read fast data from a text file
def readfast(filename):
    file=open(filename,'r')
    data=np.loadtxt(file,dtype={
    'names': ('ymd','time','JEe_s_AVG1','Je_s_AVG1','E_Char_Energy_AVG1',
    'JEi_s_AVG1','Ji_s_AVG1','I_Char_Energy_AVG1','alt','mlt','ilat'), 
    'formats': ('S1','S1','float','float','float','float','float','float','float','float','float')})
    
    # sort into parameters
    eflux=np.empty( data.shape )
    chare=np.empty( data.shape )
    invlat=np.empty( data.shape )
    for k in range(0,data.size):
        datanow=data[k]
        eflux[k]=datanow[2]
        chare[k]=datanow[4]
        invlat[k]=datanow[-1]
        
    # unit conversion, ergs to eV
    elchrg=1.6e-19
    chare=chare/1e7/elchrg

    return invlat,eflux,chare

# primitive smoothing, presumes periodic because I'm lazy
def smoothfast(lsmooth,eflux,chare):
    efluxsmooth=np.zeros(eflux.shape)
    charesmooth=np.zeros(chare.shape)
    for k in range(0,eflux.size):
        kmin=max(k-lsmooth,0)
        kmax=min(k+lsmooth+1,eflux.size)
        charesmooth[k]=np.average(chare[kmin:kmax])
        efluxsmooth[k]=np.average(eflux[kmin:kmax])
        
    return efluxsmooth,charesmooth
