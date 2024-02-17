#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 16 21:21:07 2024

@author: zettergm
"""

import numpy as np
import phys_const as const
import gemini3d.msis

def conductivity_reconstruct(time,dat,cfg, xg):
    # neutral atmospheric information
    msisparams=cfg
    msisparams
    atmos=gemini3d.msis.msis_setup(msisparams,xg)
    
       
    