#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 14 15:47:14 2022

@author: zettergm
"""

import numpy as np
from model_reconstruct import interp_amisr
import matplotlib as plt

amisr_file = "/Users/zettergm/20161127.002_lp_1min-fitcal.h5"
iso_time = "2016-11-27T22:50"
coords = [
    np.linspace(-300.0, 500.0, 50),
    np.linspace(-200.0, 600.0, 50),
    np.linspace(100.0, 500.0, 30),
]
neRISR = interp_amisr(amisr_file, iso_time, coords)
