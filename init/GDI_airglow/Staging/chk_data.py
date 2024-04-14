#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 12 13:28:43 2024

@author: zettergm
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy.interpolate
import gemini3d.coord
import gemini3d.plasma

filename="./AGP1_outline.h5"
#f=h5py.File(filename,mode="r")
#data=f["param"][:]
#f.close()

# pandas dataframe
df = pd.read_hdf(filename)
df.info()    # print the entries
print("velocity:  ", df.loc[0]["velocity (m/s)"])

# Get irregularly gridded data
ne=df.loc[0]["density field (1/m^3)"].data
glat=df.loc[0]["latitude"]
glon=df.loc[0]["longitude"]

# sanity check plot density values 
plt.figure()
plt.pcolor(glon,glat,ne)
plt.colorbar()
plt.xlabel("glon")
plt.ylabel("glat")
plt.title("$n_e$")
plt.show()

# grid the data onto a plaid glon,glat mesh
glonlist=glon[~np.isnan(glon)]
glatlist=glat[~np.isnan(glon)]
nelist=ne[~np.isnan(glon)]
gloni=np.linspace(glonlist.min(),glonlist.max(),ne.shape[0])
glati=np.linspace(glatlist.min(),glatlist.max(),ne.shape[0])
GLONi,GLATi = np.meshgrid(gloni,glati,indexing="xy")
nei = scipy.interpolate.griddata( (glonlist,glatlist), nelist, (GLONi,GLATi), fill_value=0 )
nei[np.isnan(nei)]=0

# sanity check plot sampled density values 
plt.figure()
plt.pcolor(gloni,glati,nei)
plt.colorbar()
plt.xlabel("glon")
plt.ylabel("glat")
plt.title("$n_e$")
plt.show()

# grid as plaid magnetic coords
llon=1024
llat=1024
mlatlist,mlonlist=gemini3d.coord.geog2geomag(glatlist, glonlist)
mlonlist=np.rad2deg(mlonlist)
mlatlist=np.rad2deg(np.pi/2-mlatlist)
mloni=np.linspace(mlonlist.min(),mlonlist.max(),llon)
mlati=np.linspace(mlatlist.min(),mlatlist.max(),llat)
MLONi,MLATi = np.meshgrid(mloni,mlati,indexing="xy")
nei = scipy.interpolate.griddata( (mlonlist,mlatlist), nelist, (MLONi,MLATi), fill_value=0 )
nei[np.isnan(nei)]=0

# sanity check plot sampled density values 
plt.figure()
plt.pcolor(mloni,mlati,nei)
plt.colorbar()
plt.xlabel("mlon")
plt.ylabel("mlat")
plt.title("$n_e$")
plt.show()

# do some basic smoothing, a 2 pass x, then y m-point moving average
m=7    # "radius" for moving average
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
nei[nei<1.5e11]=1.25e11

#create a 3D dataset using a Chapman profile for the altitude functional form
alt=np.linspace(80e3,600e3,256)
nei=nei.transpose((1,0))    # gemini model axis ordering
nei3D=np.empty( (alt.size,mloni.size,mlati.size) )
for ilon in range(0,mloni.size):
    for ilat in range(0,mlati.size):
            neprofile=gemini3d.plasma.chapmana(alt, nei[ilon,ilat], 300e3, 50e3)
            nei3D[:,ilon,ilat]=neprofile
            
# sanity check again
plt.figure()
plt.pcolormesh(mloni,mlati,nei3D[128,:,:].transpose())
plt.xlabel("mlon")
plt.ylabel("mlat")
plt.title("3D smoothed $n_e$ at reference alt.")
plt.colorbar()
