# Low-resolution, Comprehensive, Continuous Integration Tests

This document collects together tests of various use cases for GEMINI demonstrating a range of grids and solvers.  These can be useful reference cases to build off of or can be used to do comprehensive testing of a new deployment of GEMINI.  These tests are designed to all be runnable as a 24 hour batch job on one HPC node or a good workstation (~20-36 cores).

These test cases are too long-running to be used on every Git push.
We choose to use CMake to orchestrate these tests as CMake is a common demoninator for Gemini, and is easier and more robust for this type of task.
This taski is within the main use cases of CMake, versus a data analysis language like Matlab or Python.

These tests are intended to *supplement* (not replace) those already conducted as part of the automatic CI.  because these are too computationally expensive to run on every push they are optional but highly recommended for verifcation.

For each example there are sample commands showing how to run the exmaple using ```mpirun``` on either a small workstation (4 cores) or a large workstation (16 cores).  MPI image splits can be adjusted accordingly to best leverage whatever system one runs from.  Each test description below also briefly describes the specific GEMINI features that the example in intended to test/verify.

##  arcs\_CI

* Simulation of an auroral arc demonstrating FAC boundary conditions, nonuniform grids, and structured impact ionization
* Designed to. test simultaneous function of precipitation and field-aligned current input
* Tests 2D field-integrated solver using FAC input
* Tests non-uniform 3D Cartesian mesh capabilities
* corresponding eq simulation:  ./arcs_eq
* grid size:  98 x 96 x 96
* (future work) validation of currents using MATLAB scripts

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
* Test magnetic field calculations against an archived reference
* (future work) Could also be further run using curl(H) script to validate magcalc...

*Small workstation run:*

```sh
mpirun -np 4 ./magcalc.bin ~/simulations/arcs_CI -manual_grid 2 2 -debug -start_time 2017 3 2 27270 -end_time 2017 3 2 27300
```

* runtime:  15 mins. (one time frame)

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

Testing restart with GDI example:



## Restarting GDI\_periodic\_lowres\_CI

* The prior simulation may also be used to test the restart code for 3D simulations.  There is a milestone on the 6th (of 8th output).  By making a copy of the output and deleting the 7-8th outputs the same command can be run again to produce a restarted 7,8th output.
* These restarted outputs should be compared against the output when the restart was not used to demonstrate consistency.


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


## Restarting tohoku20112D\_medres\_axineu\_CI

* The prior simulation may also be used to test the restart code for 2D simulations with neutral inputs.  There is a milestone on the 10th output.  By making a copy of the output and deleting the remaining outputs the same command can be run again to produce a restarted version of the calculations.
* These restarted outputs should be compared against the output when the restart was not used to demonstrate consistency.  These comparisons can be restricted to the frames after the restart was conducted.


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


## cusp\_softprecip3D\_CI

* 3D open dipole simulation with particle flux and FAC inputs
* corresponding eq simulation:  ./cusp3D_eq
* tests field-resolved 2D potential solver on an open dipole grid
* grid size:  160 x 120 x 64

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


## cusp\_softprecip2D\_Dirich\_CI

* 3D open dipole simulation with particle flux and potential boudary condition inputs (Dirichlet problem)
* corresponding eq simulation:  ./cusp2D_eq
* grid size:  160 x 128 x 1

*Small workstation run:*

```sh
mpirun -np 4 ./gemini.bin ~/simulations/cusp_softprecip -manual_grid
```

* runtime:  15 mins.

*Large workstation run:*

```sh
mpirun -np 16 ./gemini.bin ~/simulations/cusp_softprecip -manual_grid
```

* runtime:  ???


## cusp\_softprecip2D\_Neu\_CI

* 3D open dipole simulation with particle flux and FAC boundary inputs (Nuemann problem)
* corresponding eq simulation:  ./cusp2D_eq
* tests field-resolved 2D potential solver on an open dipole grid with Neumann conditions
* grid size:  160 x 128 x 1

*Small workstation run:*

```sh
mpirun -np 4 ./gemini.bin ~/simulations/cusp_softprecip -manual_grid
```

* runtime:  15 mins.

*Large workstation run:*

```sh
mpirun -np 16 ./gemini.bin ~/simulations/cusp_softprecip -manual_grid
```

* runtime:  ???


# Planned Capabilities and Associated Tests

Future extension to GEMINI will also require further tests to insure the code is deployed successfully.

## cusp\_softprecip3D\_glow

* 3D open dipole simulation with particle flux input
* corresponding eq simulation:  ./cusp3D_eq
* tests field-resolved 2D potential solver with neutral inputs (2D Cartesian)
* grid size:  192 x 132 x 64
* non-finite output values for integrated volume emission rate...  Probably need to flip arrays back and forth to deal with curvilinear grid?  Could be a quick fix worth trying soon...  May also need to set inclination angle somewhere, as well.

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



## Time-dependent precipitation and fields???  ISINGLASS???
