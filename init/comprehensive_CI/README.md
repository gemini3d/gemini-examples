# Low-resolution, detailed CI tests

This document collects together tests of various use cases for GEMINI demonstrating a rangeo of grids and solvers.  These can be useful reference cases to build off of or can be used to do comprehensive testing of a new deployment of GEMINI.  These tests are designed to all be runnable as a 24 hour batch job on one HPC node or a good workstation (~20-36 cores).  

For each example there are sample commands showing how to run the exmaple using ```mpirun``` on either a small workstation (4 cores) or a large workstation (16 cores).  MPI image splits can be adjusted accordingly to best leverage whatever system one runs from.  Each test description below also briefly describes the specific GEMINI features that the example in intended to test/verify.  

##  arcs\_CI

* Simulation of an auroral arc demonstrating FAC boundary conditions, nonuniform grids, and structured impact ionization
* Designed to. test simultaneous function of precipitation and field-aligned current input
* Tests 2D field-integrated solver using FAC input
* Tests non-uniform 3D Cartesian mesh capabilities
* corresponding eq simulation:  ./arcs_eq
* grid size:  98 x 96 x 96

*Small workstation run:*

```sh
mpirun -np 4 ./gemini.bin ~/simulations/arcs_CI -manual_grid 2 2 
```

* runtime:  about 60 mins.

*Large workstation run:*

```sh
mpirun -np 16 ./gemini.bin ~/simulations/arcs_CI -manual_grid 4 4
```

* runtime:  ???

## arcs\_CI magnetic fields

* Calculates magnetic field perturbations after the arcs\_CI example has been completed.
* Test magnetic field calculations
* Can be run using curl(H) script to validate magcalc

*Small workstation run:*

```sh
mpirun -np 4 ./magcalc.bin ~/simulations/arcs_CI -manual_grid 2 2 -debug -start_time 2017 3 2 27270 -end_time 2017 3 2 27300
```

* runtime:  10 mins. (single time frame)

*Large workstation run:*

```sh
mpirun -np 16 ./magcalc.bin ~/simulations/arcs_CI -manual_grid 4 4 -debug -start_time 2017 3 2 27270 -end_time 2017 3 2 27300
```

* runtime:  ???


## GDI\_periodic\_lowres\_CI

* Simulation of gradient-drift instability on a nonuniform, periodic, lagrangian mesh
* corresponding eq simulation:  ./GDIKHI_eq
* tests field integrated solver with FAC boundary condition and background field; ionospheric capacitance option
* tests lagrangian mesh features
* grid size:  34 x 184 x 48

*Small workstation run:*

```sh
mpirun -np 4 ./gemini.bin ~/simulations/GDI_CI -manual_grid 2 2 
```

* runtime:  25 mins.

*Large workstation run:*

```sh
mpirun -np 16 ./gemini.bin ~/simulations/GDI_CI -manual_grid 4 4 
```

* runtime:  ???


## KHI\_periodic\_lowres\_CI

* Simulation of Kelvin-Helmholtz instability on a nonuniform, periodic grid
* corresponding eq simulation:  ./GDIKHI_eq
* tests field integrated solver with FAC boundary condition; magnetospheric capacitance option
* grid size:  34 x 256 x 128

*Small workstation run:*

```sh
mpirun -np 4 ./gemini.bin ~/simulations/KHI_CI -manual_grid 2 2 
```

* runtime:  80 mins.

*Large workstation run:*

```sh
mpirun -np 16 ./gemini.bin ~/simulations/KHI_CI -manual_grid 4 4 
```

* runtime:  ???


## tohoku20113D\_lowres\_3Dneu\_CI

* 3D dipole simulation with 3D neutral perturbation input.
* corresponding eq simulation:  ./tohoku20113D_eq
* tests the 3D neutral input code, which is complicated to due grid overlap calculations
* tests 2D field-integrated solver with neutral source terms
* grid size:  384 x 96 x 64

*Small workstation run:*

```sh
mpirun -np 4 ./gemini.bin ~/simulations/tohoku20113D_lowres_3Dneu_CI -manual_grid 2 2 
```

* runtime:  240 mins.

*Large workstation run:*

```sh
mpirun -np 16 ./gemini.bin ~/simulations/tohoku20113D_lowres_3Dneu_CI -manual_grid 4 4 
```

* runtime:  ???


## tohoku20113D\_lowres\_axineu\_CI

* 3D dipole simulation with 2D axisymmetric perturbation input.
* corresponding eq simulation:  ./tohoku20113D_eq
* tests the 2D axisymmetric neutral input code when applied to a 3D GEMINI grid
* grid size:  384 x 96 x 64

*Small workstation run:*

```sh
mpirun -np 4 ./gemini.bin ~/simulations/tohoku20113D_lowres_axineu_CI -manual_grid 2 2 
```

* runtime:  240 mins.

*Large workstation run:*

```sh
mpirun -np 16 ./gemini.bin ~/simulations/tohoku20113D_lowres_axineu_CI -manual_grid 4 4 
```

* runtime:  ???


## tohoku20112D\_medres\_axineu\_CI

* 2D Dipole grid simulation using axisymmetric neutral perturbations as input. 
* corresponding eq simulation:  ./tohoku20112D_eq
* tests field-resolved 2D potential solver with neutral inputs (axisymmetric)
* grid size:  512 x 512 x 1

*Small workstation run:*

```sh
mpirun -np 4 ./gemini.bin ~/simulations/tohoku20112D_medres_axineu_CI 
```

* runtime:  45 mins.

*Large workstation run:*

```sh
mpirun -np 16 ./gemini.bin ~/simulations/tohoku20112D_medres_axineu_CI 
```

* runtime:  ???


## tohoku20112D\_medres\_2Dneu\_CI

* 2D Dipole grid simulation using 2D Cartesian neutral perturbations as input. 
* corresponding eq simulation:  ./tohoku20112D_eq 
* tests field-resolved 2D potential solver with neutral inputs (2D Cartesian)
* grid size:  512 x 512 x 1

*Small workstation run:*

```sh
mpirun -np 4 ./gemini.bin ~/simulations/tohoku20112D_medres_2Dneu_CI 
```

* runtime:  45 mins.

*Large workstation run:*

```sh
mpirun -np 16 ./gemini.bin ~/simulations/tohoku20112D_medres_2Dneu_CI 
```

* runtime:  ???


## cusp\_softprecip3D

* 3D open dipole simulation with particle flux input 
* corresponding eq simulation:  ./cusp_eq 
* tests field-resolved 2D potential solver with neutral inputs (2D Cartesian)
* grid size:  192 x 132 x 64

*Small workstation run:*

```sh
mpirun -np 4 ./gemini.bin ~/simulations/cusp_softprecip -manual_grid 2 2
```

* runtime:  60 mins.

*Large workstation run:*

```sh
mpirun -np 16 ./gemini.bin ~/simulations/cusp_softprecip -manual_grid 4 4
```

* runtime:  ???