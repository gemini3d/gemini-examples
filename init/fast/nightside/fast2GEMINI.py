#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep 13 11:47:40 2021

Create GEMINI precipitation input from FAST data

@author: zettergm
"""

# imports
from fast import readfast,smoothfast


# global vars
filename="/Users/zettergm/Dropbox (Personal)/proposals/UNH_GDC/FASTdata/nightside.txt"

def fast2GEMINI():
    # read in the data
    [invlat,eflux,chare]=readfast(filename)
    
    # smooth data a bit prior to insertion into model
    lsmooth=3
    [efluxsmooth,charesmooth]=smoothfast(lsmooth,eflux,chare)
    
    # now construct space-time evoluation from these data
    
