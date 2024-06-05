#!/usr/bin/env python3
"""
@author: zettergm
"""

# imports
import gemini3d.read as read
import matplotlib.pyplot as plt
from gemini3d.grid.gridmodeldata import model2magcoords,model2geogcoords
import os

plt.ioff()    # so matplotlib doesn't take over the entire computer :(
# set some font sizes
SMALL_SIZE = 8
MEDIUM_SIZE = 10
BIGGER_SIZE = 12
plt.rc('font', size=SMALL_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=BIGGER_SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=MEDIUM_SIZE)    # fontsize of the x and y labels
plt.rc('xtick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=SMALL_SIZE)    # legend fontsize
plt.rc('figure', titlesize=BIGGER_SIZE)  # fontsize of the figure title

# load some sample data (3D)
#direc = "/Users/zettergm/simulations/ssd/ESF_periodic_lowres/"
#direc = "/Users/zettergm/simulations/ssd/GDI_periodic_lowres/"
direc = "/Users/zettergm/simulations/ssd/KHI_periodic_lowres/"
plotdir=direc+"/customplots/"
if not os.path.isdir(plotdir):
    os.mkdir(plotdir)
parmlbl="ne"


# read in simulation information grid,config
cfg = read.config(direc)
xg = read.grid(direc)
parm="ne"

plt.subplots(1,3,figsize=(11,4.5),dpi=150)
for it in range(0,len(cfg["time"])):
    dat = read.frame(direc, cfg["time"][it])
    
    ###############################################################################
    # produce gridded dataset arrays from model output for user
    ###############################################################################
    lalt=192; llon=192; llat=192;
    print("Sampling:  ",cfg["time"][it])
    malti, mloni, mlati, parmmi = model2magcoords(xg, dat[parm], lalt, llon, llat)
    
    # quickly compare flows in model components vs. geographic as a meridional slice
    plt.clf()
    plt.subplot(1,3,1)
    plt.pcolormesh(mlati,malti,parmmi[:,llon//2,:])
    plt.ylim(0,1000e3)
    plt.xlabel("mlat")
    plt.ylabel("alt")
    plt.title("$n_e$")
    plt.colorbar()
    
    plt.subplot(1,3,2)
    plt.pcolormesh(mloni,malti,parmmi[:,:,llat//2])
    plt.ylim(0,1000e3)
    plt.xlabel("mlon")
    plt.ylabel("alt")
    plt.colorbar()
    plt.title("$n_e$")
    
    plt.subplot(1,3,3)
    plt.pcolormesh(mloni,mlati,parmmi[lalt//2,:,:].transpose())
    plt.xlabel("mlon")
    plt.ylabel("mlat")
    plt.colorbar()
    plt.title("$n_e$")

    plt.savefig(plotdir+"/"+parmlbl+str(cfg["time"][it])+"s.png")
