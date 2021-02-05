# Low-resolution, detailed CI tests

This document collects together tests of various use cases for GEMINI demonstrating a rangeo of grids and solvers.  These can be useful reference cases to build off of or can be used to do comprehensive testing of a new deployment of GEMINI.  These tests are designed to all be runnable as a 24 hour batch job on one HPC node or a good workstation (~20-36 cores).  

For each example there are sample commnds showing how to run the exmaple using ```mpirun``` on either a small workstation (4 cores) or a large workstation (20 cores).  

##  arcs\_CI

* grid size:  98 x 96 x 96

Small workstation run:
```sh
mpirun -np 4 ./gemini.bin ~/simulations/arcs_CI -manual_grid 2 2 
```
* runtime:  about 60 mins.

## arcs\_CI magnetic fields


Small workstation run:
```sh
mpirun -np 4 ./magcalc.bin ~/simulations/arcs_CI -manual_grid 2 3 -debug -start_time 2017 3 2 27270 -end_time 2017 3 2 27300
```
* runtime:  10 mins. (single time frame)

## GDI\_periodic\_lowres\_CI

* grid size:  34 x 184 x 48

Small workstation run:
```sh
mpirun -np 4 ./gemini.bin ~/simulations/GDI_CI -manual_grid 2 2 
```
* runtime:  10 mins.


## KHI\_periodic\_lowres\_CI

* grid size:  34 x 256 x 128

Small workstation run
```sh
mpirun -np 4 ./gemini.bin ~/simulations/KHI_CI -manual_grid 2 2 
```
* runtime:  80 mins.


## tohoku20113D_lowres_3Dneu_CI

* grid size:  
