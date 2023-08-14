#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 14 08:16:33 2023

@author: zettergm
"""

import xarray
import numpy as np


def fac_SCW(E: xarray.Dataset, gridflag: int, flagdip: bool) -> xarray.Dataset:
    """
    for 3D sim, FAC up/down 0.5 degree FWHM
    """

    if E.mlon.size == 1 or E.mlat.size == 1:
        raise ValueError("for 3D sims only")

    #nonuniform in longitude
    shapelon = np.exp(
        -((E.mlon - E.mlonmean) ** 2) / 2 / E.mlonsig ** 2
    )
    

    # nonuniform in latitude
    shapelat = -1.0*np.exp(
        -((E.mlat - E.mlatmean - 1.5 * E.mlatsig) ** 2) / 2 / E.mlatsig ** 2
    ) + 1.0*np.exp(-((E.mlat - E.mlatmean + 1.5 * E.mlatsig) ** 2) / 2 / E.mlatsig ** 2)

    aux=E.time[1:]
    auxlength=aux.shape[0]
    auxlengthcenter=np.floor(aux.shape[0]/4)
    auxtime=E.time[int(np.floor(auxlength))]


    for t in range(1,auxlength+1):
        E["flagdirich"].loc[E.time[t]] = 0
        k = "Vminx1it" if gridflag == 1 else "Vmaxx1it"

        if t>(auxlengthcenter):
            E[k].loc[E.time[t]] = E.Jtarg * shapelon * shapelat

        else: 
            E[k].loc[E.time[t]] = E.Jtarg * shapelon * shapelat * (1/(auxlengthcenter) * (t-1))

    return E