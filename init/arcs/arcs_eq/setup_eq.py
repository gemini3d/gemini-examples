#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue May 12 13:24:05 2026

@author: zettergm
"""

import gemini3d.model
import os

# must point to the location on the current system with the msis executable
#   (i.e. requires one to first build gemini3d repository).  
os.environ["GEMINI_ROOT"]="~/Projects/gemini3d/build/_deps/msis-build/"

simdir="~/simulations/sdcard/arcs_eq/"    # location on computer where the simulation data will be kept
gemini3d.model.setup("./arcs_eq/config.nml",simdir)

# Once complete one can run (from command line pwd gemini3d build directory):
#  mpirun -np 4 ./gemini.bin <simdir>