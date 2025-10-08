#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct  2 09:41:37 2025

@author: zettergm
"""

import numpy as np
import xarray
import gemini3d.write
import gemini3d.read
import typing as T
from gemini3d.config import datetime_range
from gemini3d.particles.grid import precip_grid
from scipy.interpolate import interp1d, interp2d

# A single top-level call for creating all of the needed inputs for the run
def precip_field_inputs(cfg: dict[str, T.Any], xg: dict[str, T.Any], params: dict[str, float] = None):
    """Electric field boundary conditions and initial condition for KHI case arguments"""

    if not params:
        params = {
            "E0ref": 3000.0,
            # background flow value, actually this will be turned into a shear in the Efield input file
            "Qref":  50.0,
            "Eyref": 50e-3
        }


    # Basic information about the simulation being prepped, including current
    #   initial conditions
    x1 = xg["x1"][2:-2]
    x2 = xg["x2"][2:-2]
    lx2 = xg["lx"][1]
    lx3 = xg["lx"][2]
    dat = gemini3d.read.frame(cfg["indat_file"], var=["ns", "Ts", "v1"])

    ###########################################################################
    # Here we would call the code that adjusts the initial density profile and 
    #  otherwise changes the initial conditions
    ###########################################################################
    # nsscale = init_profile(xg, dat)
    # nsperturb = perturb_density(xg, dat, nsscale, x1, x2, params)
    #
    # %% compute initial potential, background
    # Phitop = potential_bg(x2, lx2, lx3, params)
    # Phitop = np.zeros( (lx2,lx3) )
    # Phitop = 1 * np.random.randn(lx2, lx3)  # seed potential with random noise
    # Phitop[0:9,:]=0.0
    # Phitop[-10:-1,:]=0.0
    #
    # # %% Write initial plasma state out to a file
    # gemini3d.write.state(
    #     cfg["indat_file"],
    #     dat,
    #     ns=nsperturb,
    #     Phitop=Phitop,
    # )
    # dat["ns"].data = nsperturb

    ###########################################################################
    # create precipitation inputs
    ###########################################################################
    create_precip(cfg, xg, params)

    ###########################################################################
    # %% Electromagnetic parameter inputs
    ###########################################################################
    create_Efield(cfg, xg, params)
    

def create_precip(cfg: dict[str, T.Any], xg: dict[str, T.Any], params: dict[str, float] = None):
    """write particle precipitation to disk"""

    # %% CREATE PRECIPITATION INPUT DATA
    # Q: energy flux [mW m^-2]
    # E0: characteristic energy [eV]

    ###########################################################################
    # Set some default sizes.  
    ###########################################################################
    llon = 512
    llat = 512
    # NOTE: cartesian-specific code
    if xg["lx"][1] == 1:
        llon = 1
    elif xg["lx"][2] == 1:
        llat = 1

    ###########################################################################
    # Construct the grid structure and space to store the precipitation data.  
    #   Internally GEMINI will handle things in mlong and mlat coordinates; the
    #   user can create them in whatever way they want so this code could contain
    #   additional coordinate definitions and transformations.  
    ###########################################################################   
    thetamin = xg["theta"].min()
    thetamax = xg["theta"].max()
    mlatmin = 90 - np.degrees(thetamax)
    mlatmax = 90 - np.degrees(thetamin)
    mlonmin = np.degrees(xg["phi"].min())
    mlonmax = np.degrees(xg["phi"].max())

    # add a 1% buff
    latbuf = 0.01 * (mlatmax - mlatmin)
    lonbuf = 0.01 * (mlonmax - mlonmin)

    time = datetime_range(cfg["time"][0], cfg["time"][0] + cfg["tdur"], cfg["dtprec"])
    pg = xarray.Dataset(
        {
            "Q": (("time", "mlon", "mlat"), np.zeros((len(time), llon, llat))),
            "E0": (("time", "mlon", "mlat"), np.zeros((len(time), llon, llat))),
        },
        coords={
            "time": time,
            "mlat": np.linspace(mlatmin - latbuf, mlatmax + latbuf, llat),
            "mlon": np.linspace(mlonmin - lonbuf, mlonmax + lonbuf, llon),
        },
    )
    lt = pg.time.size   # convenience variable for number of time frames used for precipitation

    ###########################################################################
    # INTERPOLATE COORDINATEs ONTO PROPOSED MLON GRID -- this is so the functions
    #    That set the precipitation and field values can use the native model
    #    coordinates (x2,3) is so desired.  
    ###########################################################################
    xgmlon = np.degrees(xg["phi"][0, :, 0])
    xgmlat = 90 - np.degrees(xg["theta"][0, 0, :])
    f = interp1d(xgmlon, xg["x2"][2:xg["lx"][1] + 2], kind="linear", fill_value="extrapolate")
    x2i = f(pg["mlon"])
    f = interp1d(xgmlat, xg["x3"][2:xg["lx"][2] + 2], kind='linear', fill_value="extrapolate")
    x3i = f(pg["mlat"])

    ###########################################################################
    # Make the calls to compute the precipitation and field information and write
    #   the data to files compatible with GEMINI.  
    ###########################################################################
    pg["Q"].data = Q_shape(pg, params, x2i, x3i)
    pg["E0"].data = E0_shape(pg, params, x2i, x3i)
    assert np.isfinite(pg["Q"]).all(), "Q flux must be finite"
    assert (pg["Q"] >= 0).all(), "Q flux must be non-negative"
    assert np.isfinite(pg["E0"]).all(), "E0 flux must be finite"
    assert (pg["E0"] >= 0).all(), "E0 flux must be non-negative"
    gemini3d.write.precip(pg, cfg["precdir"])


def Q_shape(pg, params, x2i, x3i):
    """
    makes a 2D Gaussian shape in x2i,x3i, and time of total energy flux
    """
    
    # Conversion of time into seconds from beginning of simulation
    timeref = pg.time[0]
    timesec = np.empty(pg.time.size)
    for it in range(0, pg.time.size):
        dt = pg.time[it].values - timeref.values
        timesec[it] = dt.astype("timedelta64[s]").item().total_seconds()

    meanx2=x2i.mean()
    meanx3=x3i.mean()
    sigx2=1/5*(x2i.max()-x2i.min())
    sigx3=1/120*(x3i.max()-x3i.min())
    displace = 3 * sigx3
    #meant=timesec.mean()
    meant = 300
    # t_sigma=1/8*(_times.min()+_times.max())
    sigt = 150
    
    X2i,X3i = np.meshgrid(x2i,x3i,indexing="ij")
    
    x3ctr = meanx2 + displace * np.tanh((X2i -meanx2) / (2 * sigx2))
    
    Q=np.zeros((pg.time.size,pg.mlon.size,pg.mlat.size))
        
    for it in range(0,pg.time.size):
        Q[it,:,:] =  ( params["Qref"] * np.exp(-((X2i - meanx2) ** 2) / 2 / sigx2**2) * 
                 np.exp(-((X3i - x3ctr + 1.5 * sigx3) ** 2) / 2 / sigx3**2) 
                 * np.exp(-((timesec[it] - meant) ** 2) / 2 / sigt**2) )
        
    return Q.clip(min=1e-6)    


def E0_shape(pg, params, x2i, x3i):
    """
    makes a 2D Gaussian shape in x2i,x3i, and time of characteristic energy
    """
    
    # # Conversion of time into seconds from beginning of simulation
    # timeref = pg.time[0]
    # timesec = np.empty(pg.time.size)
    # for it in range(0, pg.time.size):
    #     dt = pg.time[it].values - timeref.values
    #     timesec[it] = dt.astype("timedelta64[s]").item().total_seconds()

    # meanx2=x2i.mean()
    # meanx3=x3i.mean()
    # sigx2=1/20*(x2i.max()-x2i.min())
    # sigx3=1/20*(x3i.max()-x3i.min())
    # displace = 3 * sigx3
    
    # #meant=timesec.mean()
    # meant = 300
    # # t_sigma=1/8*(_times.min()+_times.max())
    # sigt = 150
    
    # X2i,X3i = np.meshgrid(x2i,x3i,indexing="ij")
    
    # x3ctr = meanx2 + displace * np.tanh((X2i -meanx2) / (2 * sigx2))
    
    E0=np.zeros((pg.time.size,pg.mlon.size,pg.mlat.size))
    # for it in range(0,pg.time.size):
    #     Q[it,:,:] =  -( params["Qref"] * np.exp(-((X2i - meanx2) ** 2) / 2 / sigx2**2) * 
    #              np.exp(-((X3i - x3ctr + 1.5 * sigx3) ** 2) / 2 / sigx3**2) 
    #              * np.exp(-((timesec - meant) ** 2) / 2 / sigt**2) )
    
    E0=params["E0ref"]*np.ones((pg.time.size,pg.mlon.size,pg.mlat.size))

    return E0.clip(min=101.0)    


def create_Efield(cfg: dict[str, T.Any], xg: dict[str, T.Any], params: dict[str, float] = None):

    ###########################################################################
    # Set some default sizes.  
    ###########################################################################
    llon = 512
    llat = 512
    # NOTE: cartesian-specific code
    if xg["lx"][1] == 1:
        llon = 1
    elif xg["lx"][2] == 1:
        llat = 1

    ###########################################################################
    # Construct the grid structure and space to store the precipitation data.  
    #   Internally GEMINI will handle things in mlong and mlat coordinates; the
    #   user can create them in whatever way they want so this code could contain
    #   additional coordinate definitions and transformations.  
    ########################################################################### 
    thetamin = xg["theta"].min()
    thetamax = xg["theta"].max()
    mlatmin = 90 - np.degrees(thetamax)
    mlatmax = 90 - np.degrees(thetamin)
    mlonmin = np.degrees(xg["phi"].min())
    mlonmax = np.degrees(xg["phi"].max())

    # add a 1% buff
    latbuf = 0.01 * (mlatmax - mlatmin)
    lonbuf = 0.01 * (mlonmax - mlonmin)

    E = xarray.Dataset(
        coords={
            "time": datetime_range(cfg["time"][0], cfg["time"][0] + cfg["tdur"], cfg["dtE0"]),
            "mlat": np.linspace(mlatmin - latbuf, mlatmax + latbuf, llat),
            "mlon": np.linspace(mlonmin - lonbuf, mlonmax + lonbuf, llon),
        }
    )
    lt = E.time.size

    # %% CREATE DATA FOR BACKGROUND ELECTRIC FIELDS
    E["Exit"] = (("time", "mlon", "mlat"), np.zeros((lt, llon, llat)))
    E["Eyit"] = (("time", "mlon", "mlat"), np.zeros((lt, llon, llat)))
    # %% CREATE DATA FOR BOUNDARY CONDITIONS FOR POTENTIAL SOLUTION
    # if 0 data is interpreted as FAC, else we interpret it as potential
    E["flagdirich"] = (("time",), np.zeros(lt, dtype=np.int32))
    E["Vminx1it"] = (("time", "mlon", "mlat"), np.zeros((lt, llon, llat)))
    E["Vmaxx1it"] = (("time", "mlon", "mlat"), np.zeros((lt, llon, llat)))
    # these are just slices
    E["Vminx2ist"] = (("time", "mlat"), np.zeros((lt, llat)))
    E["Vmaxx2ist"] = (("time", "mlat"), np.zeros((lt, llat)))
    E["Vminx3ist"] = (("time", "mlon"), np.zeros((lt, llon)))
    E["Vmaxx3ist"] = (("time", "mlon"), np.zeros((lt, llon)))

    ###########################################################################
    # INTERPOLATE COORDINATEs ONTO PROPOSED MLON GRID -- this is so the functions
    #    That set the precipitation and field values can use the native model
    #    coordinates (x2,3) is so desired.  
    ###########################################################################
    xgmlon = np.degrees(xg["phi"][0, :, 0])
    xgmlat = 90 - np.degrees(xg["theta"][0, 0, :])
    f = interp1d(xgmlon, xg["x2"][2 : xg["lx"][1] + 2], kind="linear", fill_value="extrapolate")
    x2i = f(E["mlon"])
    f = interp1d(xgmlat, xg["x3"][2 : xg["lx"][2] + 2], kind="linear", fill_value="extrapolate")
    x3i = f(E["mlat"])

    ###########################################################################
    # Make the calls to compute the precipitation and field information and write
    #   the data to files compatible with GEMINI.  
    ###########################################################################
    E["Exit"].data,E["Eyit"].data = Efield_shape(E, params, x2i, x3i)
    gemini3d.write.Efield(E, cfg["E0dir"])


def Efield_shape(E, params, x2i, x3i):
    """
    Set the top boundary shape elements in the Efield structure
    """
    
    # Conversion of time into seconds from beginning of simulation
    timeref = E.time[0]
    timesec = np.empty(E.time.size)
    for it in range(0, E.time.size):
        dt = E.time[it].values - timeref.values
        timesec[it] = dt.astype("timedelta64[s]").item().total_seconds()

    meanx2=x2i.mean()
    meanx3=x3i.mean()
    sigx2=1/5*(x2i.max()-x2i.min())
    sigx3=1/120*(x3i.max()-x3i.min())
    displace = 3 * sigx3
    #meant=timesec.mean()
    meant = 300
    # t_sigma=1/8*(_times.min()+_times.max())
    sigt = 150
    
    X2i,X3i = np.meshgrid(x2i,x3i,indexing="ij")
    
    x3ctr = meanx2 + displace * np.tanh((X2i -meanx2) / (2 * sigx2))
    
    Ey=np.zeros((E.time.size,E.mlon.size,E.mlat.size))
    for it in range(0,E.time.size):
        Ey[it,:,:] =  -( params["Eyref"] * np.exp(-((X2i - meanx2) ** 2) / 2 / sigx2**2) * 
                 np.exp(-((X3i - x3ctr - 1.5 * sigx3) ** 2) / 2 / sigx3**2) 
                 * np.exp(-((timesec[it] - meant) ** 2) / 2 / sigt**2) )

    Ex=np.zeros((E.time.size,E.mlon.size,E.mlat.size))
    for it in range(0,E.time.size):
        Eyx,Eyy = np.gradient(Ey[it,:,:],x2i,x3i)
        for i in range(0,E.mlon.size):
            for j in range (0,E.mlat.size):
                Ex[it, i, j]=np.trapz(Eyx[i,0:j+1],x3i[0:j+1])

    return Ex,Ey