# Low-resolution, detailed CI tests

This document collects together tests of various use cases for GEMINI demonstrating a rangeo of grids and solvers.  These can be useful reference cases to build off of or can be used to do comprehensive testing of a new deployment of GEMINI.  These tests are designed to all be runnable as a 24 hour batch job on one HPC node or a good workstation (~20-36 cores).  

##  arcs_CI

* grid size:  98 x 96 x 96

```sh
mpirun -np 6 ./gemini.bin ~/simulations/arcs_CI -manual_grid 3 2 
```

## arcs_CI magnetic fields

```sh
mpirun -np 6 ./magcalc.bin ~/simulations/arcs_CI -manual_grid 2 3 -debug -start_time 2017 3 2 27270 -end_time 2017 3 2 27300
```

