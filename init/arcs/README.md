# Auroral Arcs Examples

This example shows an application of the GEMINI model to simulate a 3D auroral arc.  The simulation is driven by application of a field-aligned currents at the top boundary, as well as precipitation particles.  The basic setup of this example is an arc that is elongated in longitude (~1000 km) and thin in latitude (~20km or so).  Steps to run and alter these examples are given in sections below.

There are currently two ARCs examples, others will be developed in the near future:

1. The standard configuration which is a straight arc that tapers in intensity with longitude in ./standard
2. An arc situated at an angle to the background flow in ./angle

## GEMINI Installation

Before attempting to run this example you will need to do a full GEMINI installation as described in the README for the core [GEMINI](https://github.com/gemini3d/gemini) repository.  You will also need to install the [gemini-examples](https://github.com/gemini3d/gemini-examples) repository and the [mat_gemini](https://github.com/gemini3d/mat_gemini) repositories.  


## Equilibrium Simulation

Generate an equilibrium simulation for this example using the [ARCs\_eq example](../init/arcs_eq) or another simulations that you have set up.  Alternatively one may request input data from one of the repo maintainers, but there is not gaurantee of a timely response and/or the input data may be quite large and unwieldy to transfer across a network.


## Disturbance Simulation Setup

It is now possible to set up basic auroral arc simulations (viz. simulations with arbirary precipitation and field-aligned current inputs) by using generic routines provided in the mat_gemini respostory using ```model_setup``` as follows.  Navigate to the par

```MATLAB
gemini3d.setup.model_setup("config.nml")
```

The example config.nml files included in this directory illustrate how to use various namelist variables to control, e.g. width and intensity of precipitation and other parameters.  For creating one's own precipitation and current density boundary see ./angle/config.nml which shows how to specify custom user-defined functions for current and precipitation patterns.  


<!---
3. Define a new grid using parameters in the config.nml file in this directory.  The .nml file can be edited to adjust the grid extent and resolution (number of grid points), grid center location, and local geomagnetic field inclination.

4. Define parameters in the ```config.nml``` file for the field-aligned boundary currents.  The peak current density and width of the current distribution can be adjusted via the parameters:

	```
	Jtarg = 30e-6                  ! max field aligned current (A/m^2) at the top boundary
    Efield_lonwidth = 0.15.      ! fraction of the grid in longitude spanned by the current density perturbation
    Efield_latwidth = 0.025.     ! fraction of the grid in latitude "
	```
	In addition to these basic parameters, one must also specify the shape of the current density pattern imposed at the top boundary.  For now this can be done by directly editing the ```Efield_BCs_3d.m``` script, particularly the functions ```Efield_target``` and ```Jcurrent_target```.  Future releases will likely wrap this functionality into a user-defined shape function that can be provided to the ```model_setup.m``` script but for now we have not yet had time to implement that.

5. Define parameters for the precipitation being applied at the top boundary of the simulations.  The max total energy flux and characteristic energy are defined for two precipitation particle populations:  background (diffuse) precipitation and auroral (disturbance) precipitation.  These are specified in the following parameters in the ```config.nml``` file:

	```
	precip_latwidth = 0.025        ! fraction of the grid (latitude) "
	precip_lonwidth = 0.15			! fraction of the grid (longitude) spanned by the precipitation
	Qprecip = 25					! disturbance max total energy flux (mW/m^2)
	Qprecip_background = 1			! background total energy flux (mW/m^2)
	E0precip = 2e3                 ! energy (eV) of the precipitation
	```
	The shape of the precipitation can be specified by altering the ```precip_gaussian2d.m``` function; in a later release the user will be able to provide a pointer to their own function for the shape parameter.

6. Load mat_gemini by navigating into that directory and execute (from MATLAB):   ```>> setup```

7. Run the top-level MATLAB script to generate files for initial and boundary conditions for this simulation.  Navigate to this directory in the MATLAB command window and then execute:  ```>> gemini3d.setup.model_setup('config.nml')```
You should see a bunch of console output in MATLAB to verify that the grid is being created and HDF5 input files for the fortran code are being written.
-->


## Launching Disturbance Simulation

After running model_setup this simulation may be run from the command line by:

	```sh
	mpirun -np 8 ./gemini.bin path/outputdirectory/ -manual_grid 2 4
	```
	
It will take approximately several hours to complete on a 4-8 core system; It is recommended that one use at least 16-32 cores, if available, to speed the calculations.  It is possible to use up to ~192 cores with this example if you manually specify the mpi split in x2 and x3, e.g.:

	```
	mpirun -np 192 ./gemini.bin path/outputdirectory/ -manual_grid 16 12
	```
