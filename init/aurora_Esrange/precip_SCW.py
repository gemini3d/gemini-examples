#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 14 08:46:57 2023

@author: zettergm
"""

import numpy as np
import xarray
from fac_input_to_matt import fac_input

def precip_SCW(pg: xarray.Dataset, Qpeak: float, Qbackground: float):
    mlon_mean = pg.mlon.mean().item()
    mlat_mean = pg.mlat.mean().item()

    # Set some parameters
    centerlon = 105 # the longitudinal cenrte (in degrees) of SCW structure
    width = 90 # longitudinal width in degrees of SCW feature
    #scaling = 10 # increase the resulting FAC magnitudes, since the fitted values are too small (AMPERE does not capture small scale stuff)
    #duration = 200 # duration of time to model, in minutes
    #sigmat = 20 # Sigma of the Gaussian temporal modulation of the pattern [minutes]
    
    # Make evaluation locations
    lt=pg.time.size
    timeref=pg.time[0]
    timesec=np.empty(lt)
    for it in range(0,lt):
        dt=pg.time[it].values-timeref.values
        timesec[it]=dt.astype('timedelta64[s]').item().total_seconds()
    _times = timesec/60    #temporal locations to evaluare for FAC [minuted]
    _mlats=pg.mlat
    _mlons=pg.mlon

    # Discrete auroral precipitation
    times, mlats, mlons = np.meshgrid(_times, _mlats, _mlons, indexing='ij') # make 3D grid of locations
    fac = fac_input(times, mlons, mlats, centerlon=centerlon, sigmat=5, width=width, scaling=5, duration=5) # [A/m2]
    facscaled=fac/fac.max()    # scaling for discrete part of precipitation
    Q=np.empty((lt,_mlons.size,_mlats.size))
    for it in range(0,_times.size):
        Q[it,:,:] = facscaled[it,:,:].transpose((1,0))*Qpeak
        
    Q[Q < Qbackground] = Qbackground
        
    # Auroral oval slowly varying precipitation
    Qoval=5
    for it in range(0,_times.size):
        Q[it,:,:]=Q[it,:,:]+Qoval*np.exp(-(mlats[0,:,:].transpose((1,0))-70.0)**2/2/(4)**2)

    # if "mlon_sigma" in pg.attrs and "mlat_sigma" in pg.attrs:
    #     Q = (
    #         Qpeak
    #         * np.exp(
    #             -((pg.mlon.data[:, None] - mlon_mean) ** 2) / (2 * pg.mlon_sigma**2)
    #         )
    #         * np.exp(
    #             -((pg.mlat.data[None, :] - mlat_mean) ** 2) / (2 * pg.mlat_sigma**2)
    #         )
    #     )
    # elif "mlon_sigma" in pg.attrs:
    #     Q = Qpeak * np.exp(
    #         -((pg.mlon.data[:, None] - mlon_mean) ** 2) / (2 * pg.mlon_sigma**2)
    #     )
    # elif "mlat_sigma" in pg.attrs:
    #     Q = Qpeak * np.exp(
    #         -((pg.mlat.data[None, :] - mlat_mean) ** 2) / (2 * pg.mlat_sigma**2)
    #     )
    # else:
    #     raise LookupError("precipation must be defined in latitude, longitude or both")
        
    return Q