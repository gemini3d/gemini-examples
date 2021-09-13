"""
Created on Fri Sep 10 18:32:11 2021

Date
Time
Electron energy flux (ergs/cm2-s)
Electron number flux (1/cm2-s)
Electron characteristic energy (ergs)
Ion energy flux (ergs/cm2-s)
Ion number flux (1/cm2-s)
Ion characteristic energy (ergs)
Altitude (km)
MLT (decimal hours)
Invariant latitude (degrees)

@author: zettergm
"""

import matplotlib.pyplot as plt
from fast import readfast,smoothfast

# read in the data
filename="/Users/zettergm/Dropbox (Personal)/proposals/UNH_GDC/FASTdata/nightside.txt"
#filename="/Users/zettergm/Dropbox (Personal)/proposals/UNH_GDC/FASTdata/cusp.txt"
[invlat,eflux,chare]=readfast(filename)

# smooth data a bit prior to inserting into model
lsmooth=3
[efluxsmooth,charesmooth]=smoothfast(lsmooth,eflux,chare)

# plot
plt.subplots(1,2,dpi=100)

plt.subplot(1,2,1)
plt.plot(invlat,eflux)
plt.plot(invlat,efluxsmooth)
plt.ylim([0,50])
plt.xlabel("latitude (deg.)")
plt.ylabel("energy flux (mW/m$^2$)")
plt.legend(["data","smooth"])

plt.subplot(1,2,2)
plt.plot(invlat,chare)
plt.plot(invlat,charesmooth)
plt.ylim([0,10000])
plt.xlabel("latitude (deg.)")
plt.ylabel("energy (eV)")
plt.legend(["data","smooth"])
