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
#import h5py
#from model_reconstruct import interp_amisr

import matplotlib.pyplot as plt

#from volumetricinterp.interp4model import CalcInterp
#targtime = np.datetime64('2017-11-21T19:20')

def perturb_file(cfg: T.Dict[str, T.Any], xg: T.Dict[str, T.Any]):
    ###########################################################################
    # Organize mesh coordinate data 
    ###########################################################################
    x1 = xg["x1"][2:-2]
    x2 = xg["x2"][2:-2]
    x3 = xg["x3"][2:-2]    
    #x = x2
    #y = x3
    #z = x1
    #X, Y, Z = np.meshgrid(x, y, z)
    
    # read in electron density data
    # h5f=h5py.File("/Users/zettergm/simulations/raid/RISR_staging_data_highres/inputs/nexyz.h5","r")
    # neRISR=h5f["Ne"][:]
    # h5f.close()
    #amisr_file = '/Users/zettergm/20161127.002_lp_1min-fitcal.h5'
    #iso_time = '2016-11-27T22:50'
    #amisr_file = "/Users/zettergm/20171119.001_lp_1min-fitcal.h5"
    
    ###########################################################################
    # Read data from source file
    ###########################################################################
    #X_prime = (X * np.cos(-81 * np.pi/180) - Y * np.sin(-81 * np.pi/180))
    #Y_prime = (X * np.sin(-81 * np.pi/180) + Y * np.cos(-81 * np.pi/180))
    #X_prime_prime = X_prime + 50e3
    #Y_prime_prime = Y_prime + 200e3

    #ci = CalcInterp('/Users/redden/Desktop/RISR/Run_18_49/volumetric_interp_output.h5')
    #neRISR = ci.point_enu(np.datetime64(iso_time), X_prime_prime, Y_prime_prime, Z)
    #neRISR=neRISR.transpose((2,0,1))
    
    alti,mloni,mlati,neAGP=AGP2model("./AGP1_outline.h5",xg,m=5,fillvalue=1.25e11)
    
    plt.figure()
    plt.pcolormesh(mloni,mlati,neAGP[23,:,:].transpose())
    plt.xlabel("mlon")
    plt.ylabel("mlat")
    plt.title("3D smoothed $n_e$ at reference alt.")
    plt.colorbar()
    
    ###########################################################################
    # Scale plasma density to account for decay during staging simulation and
    #   distribute to various ion species with error checking
    ###########################################################################

    #WARNING total hack
    neAGP=1.4*neAGP   # keep the prominence the same for a 10 minute staging/settling
    
    # amisr_file = '/Users/e30737/Desktop/Data/AMISR/RISR-N/2017/20171119.001_lp_1min-fitcal.h5'
    # iso_time = '2017-11-21T19:20'
    # coords = [x2, x3, x1]
    # neRISR=interp_amisr(amisr_file, iso_time, coords)
    
    # distribute to various ions
    nsperturb=np.empty((7,x1.size,x2.size,x3.size))
    nsperturb[6,:,:,:]=neAGP
    comp=1/2+1/2*tanh((x1-200e3)/15e3)
    for i in range(0,x2.size):
        for j in range(0,x3.size):
            nmolec=(1-comp)*neAGP[:,i,j]
            natomic=comp*neAGP[:,i,j]
            nsperturb[0,:,i,j]=0.98*natomic
            nsperturb[4,:,i,j]=0.01*natomic
            nsperturb[5,:,i,j]=0.01*natomic
            nsperturb[1,:,i,j]=1/3*nmolec
            nsperturb[2,:,i,j]=1/3*nmolec
            nsperturb[3,:,i,j]=1/3*nmolec        
    
    # enforce nonzero min density
    nsperturb = np.maximum(nsperturb, 1e4)
    nsperturb[6,:,:,:]=np.sum(nsperturb[0:5,:,:,:],axis=0)
       
    ###########################################################################
    # Write in a format GEMINI can handle
    ###########################################################################
    # read in original reference data; we will retain flows and temperatures
    dat = gemini3d.read.data(cfg["indat_file"], var=["ns", "Ts", "vs1"])
    
    gemini3d.write.state(
    cfg["indat_file"],
    dat,
    ns=nsperturb
    )
    

def AGP2model(filename,xg,m=0,fillvalue=1.25e11):
    import gemini3d.coord
    import gemini3d.plasma
    import scipy.interpolate
    import pandas as pd

    # pandas dataframe
    df = pd.read_hdf(filename)
    
    # Get irregularly gridded data
    ne=df.loc[0]["density field (1/m^3)"].data
    glat=df.loc[0]["latitude"]
    glon=df.loc[0]["longitude"]
    
    # array of points with actual data
    glonlist=glon[~np.isnan(glon)]
    glatlist=glat[~np.isnan(glon)]
    nelist=ne[~np.isnan(glon)]
    mlatlist,mlonlist=gemini3d.coord.geog2geomag(glatlist, glonlist)
    mlonlist=np.rad2deg(mlonlist)
    mlatlist=np.rad2deg(np.pi/2-mlatlist)
    
    # grid as plaid magnetic coords using GEMINI mesh extents to define query
    #   locations
    mloni=np.rad2deg(xg["phi"][0,:,0])
    mlati=np.rad2deg(np.pi/2-xg["theta"][0,0])
    MLONi,MLATi = np.meshgrid(mloni,mlati,indexing="xy")
    nei = scipy.interpolate.griddata( (mlonlist,mlatlist), nelist, (MLONi,MLATi), fill_value=0 )
    nei[np.isnan(nei)]=fillvalue
    
    # do some basic smoothing, a 2 pass x, then y m-point moving average, tile
    #   dataset with "ghost cells" to make this cleaner to code
    neiextended=np.concatenate( (nei[0:m,:],nei,nei[-m:,:]), axis=0 )
    neiextended=np.concatenate( (neiextended[:,0:m],neiextended,neiextended[:,-m:]), axis=1 )
    neismooth=neiextended
    for i in range(0,nei.shape[0]):
        neismooth[i,:]=1/(2*m+1)*np.sum( neiextended[i-m:i+m+1,:], axis=0 )
    for j in range(0,nei.shape[0]):
        neiextended[:,j]=1/(2*m+1)*np.sum( neismooth[:,j-m:j+m+1], axis=1)
    if m>0:
        nei=neiextended[m:-m,m:-m]
    else:
        nei=neiextended
        
    # enforce some minimum background density
    nei[nei<fillvalue]=fillvalue
    
    #create a 3D dataset using a Chapman profile for the altitude functional form
    alti=xg["x1"][2:-2]          # adopt sampling from model
    nei=nei.transpose((1,0))     # gemini model axis ordering
    nei3D=np.empty( (alti.size,mloni.size,mlati.size) )
    for ilon in range(0,mloni.size):
        for ilat in range(0,mlati.size):
                neprofile=gemini3d.plasma.chapmana(alti, nei[ilon,ilat], 300e3, 50e3)
                nei3D[:,ilon,ilat]=neprofile
    
    return alti,mloni,mlati,nei3D
    