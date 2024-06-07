#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 13 11:47:40 2021

Create GEMINI precipitation input from FAST data

@author: zettergm
"""

# imports
# import typing as T
import numpy as np
import xarray
import gemini3d.write as write
from gemini3d.config import datetime_range
import matplotlib.pyplot as plt
from fast import readfast, smoothfast

# global vars
pi = np.pi
filename = "/Users/zettergm/Dropbox (Personal)/proposals/UNH_GDC/FASTdata/cusp.txt"
debug = True


def fast2GEMINI(cfg, xg):
    # output dict.
    pg = {}

    # read in the data
    [invlat, eflux, chare] = readfast(filename)

    # smooth data a bit prior to insertion into model
    lsmooth = 0
    [efluxsmooth, charesmooth] = smoothfast(lsmooth, eflux, chare)

    # basic grid info
    gridmlat = 90 - xg["theta"] * 180 / pi
    gridmlon = xg["phi"] * 180 / pi
    mlatmin = np.min(gridmlat)
    mlatmax = np.max(gridmlat)
    mlonmin = np.min(gridmlon)
    mlonmax = np.max(gridmlon)

    # precipitation input grids
    llon = 128
    llat = invlat.size
    mlon = np.linspace(mlonmin, mlonmax, llon)
    mlat = invlat
    mlonctr = np.average(mlon)
    mlatctr = np.average(mlat)

    # fast data may need to be sorted along the latitude axis
    isort = np.argsort(mlat)
    mlat = mlat[isort]
    efluxsmooth = efluxsmooth[isort]
    charesmooth = charesmooth[isort]

    # for convenience recenter grid on what the user has made
    # dmlat=np.average(gridmlat)-mlatctr
    dmlat = 0
    mlat = mlat + dmlat

    # time grid for precipitation
    time = datetime_range(cfg["time"][0], cfg["time"][0] + cfg["tdur"], cfg["dtprec"])
    lt = len(time)
    t = np.empty((lt))
    for k in range(0, lt):
        t[k] = time[k].timestamp()
    meant = np.average(t)

    # longitude shape
    Q = np.empty((lt, llon, llat))
    E0 = np.empty((lt, llon, llat))
    siglon = 5
    sigt = 100
    for k in range(0, lt):
        tshape = np.exp(-((t[k] - meant) ** 2) / 2 / sigt**2)
        for ilon in range(0, llon):
            lonshape = np.exp(-((mlon[ilon] - mlonctr) ** 2) / 2 / siglon**2)
            Q[k, ilon, :] = tshape * lonshape * efluxsmooth[:]
            E0[k, ilon, :] = charesmooth[:]

    # fill values
    Q[Q < 0] = 0
    E0[E0 < 101] = 101

    # create xarray dataset
    pg = xarray.Dataset(
        {
            "Q": (("time", "mlon", "mlat"), Q),
            "E0": (("time", "mlon", "mlat"), E0),
        },
        coords={
            "time": time,
            "mlat": mlat,
            "mlon": mlon,
        },
    )

    # make a representative plot if required
    if debug:
        plt.subplots(1, 2, dpi=100)
        plt.subplot(1, 2, 1)
        plt.pcolormesh(mlon, mlat, Q[lt // 2, :, :].transpose())
        plt.colorbar()
        plt.title("energy flux")
        plt.xlabel("mlon")
        plt.ylabel("mlat")
        plt.subplot(1, 2, 2)
        plt.pcolormesh(mlon, mlat, E0[lt // 2, :, :].transpose())
        plt.colorbar()
        plt.title("char. en.")
        plt.xlabel("mlon")
        plt.ylabel("mlat")
        plt.show(block=False)

    # write these to the simulation input directory
    write.precip(pg, cfg["precdir"], cfg["file_format"])
    return
