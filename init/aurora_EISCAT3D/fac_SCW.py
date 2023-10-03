#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 14 08:16:33 2023

@author: zettergm
"""

import xarray
import numpy as np
from fac_input_to_matt import fac_input

def fac_SCW(E: xarray.Dataset, gridflag: int, flagdip: bool) -> xarray.Dataset:
    """
    for 3D sim, FAC up/down 0.5 degree FWHM
    """

    if E.mlon.size == 1 or E.mlat.size == 1:
        raise ValueError("for 3D sims only")

    # Set some parameters
    centerlon = 105 # the longitudinal cenrte (in degrees) of SCW structure
    width = 90 # longitudinal width in degrees of SCW feature
    #scaling = 10 # increase the resulting FAC magnitudes, since the fitted values are too small (AMPERE does not capture small scale stuff)
    #duration = 200 # duration of time to model, in minutes
    #sigmat = 20 # Sigma of the Gaussian temporal modulation of the pattern [minutes]
    
    # Make evaluation locations
    lt=E.time.size
    timeref=E.time[0]
    timesec=np.empty(lt)
    for it in range(0,lt):
        dt=E.time[it].values-timeref.values
        timesec[it]=dt.astype('timedelta64[s]').item().total_seconds()
    _times = timesec/60    #temporal locations to evaluare for FAC [minuted]
    _mlats=E.mlat
    _mlons=E.mlon
    #_mlats = np.linspace(50, 85, 800) # mlats to evaluate [degrees]
    #_mlons = np.linspace(centerlon-width*0.5, centerlon+width*0.5, 100) # mlons to evaluate [degrees]
    #shape = (_times.size, _mlats.size, _mlons.size)
    times, mlats, mlons = np.meshgrid(_times, _mlats, _mlons, indexing='ij') # make 3D grid of locations
    fac = fac_input(times, mlons, mlats, centerlon=centerlon, sigmat=5, width=width, scaling=5, duration=5) # [A/m2]

    #aux=E.time[1:]
    #auxlength=aux.shape[0]
    #auxlengthcenter=np.floor(aux.shape[0]/4)
    #auxtime=E.time[int(np.floor(auxlength))]

    for t in range(0,E.time.size):
        E["flagdirich"].loc[E.time[t]] = 0
        k = "Vminx1it" if gridflag == 1 else "Vmaxx1it"

        E[k].loc[E.time[t]] = fac[t,:,:].transpose((1,0))    # order as mlon, mlat for GEMINI
    #    if t>(auxlengthcenter):
    #        E[k].loc[E.time[t]] = E.Jtarg * shapelon * shapelat
    #    else: 
    #        E[k].loc[E.time[t]] = E.Jtarg * shapelon * shapelat * (1/(auxlengthcenter) * (t-1))

    return E