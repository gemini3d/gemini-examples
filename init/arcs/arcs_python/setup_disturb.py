#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May 12 13:24:05 2026

@author: zettergm
"""

# In order to manipulate the precipitation and electric field inputs one needs
#   modify the precip_field_inputs.py script.  Alternatively one could write one's
#   own data processing procedures and plug them in here as well.  

import gemini3d.model

simdir="~/simulations/sdcard/arcs_python/"    # location on computer where the simulation data will be kept
gemini3d.model.setup("./config.nml",simdir)

# Once complete one can run (from command line pwd gemini3d build directory):
#  mpirun -np 4 ./gemini.bin <simdir>