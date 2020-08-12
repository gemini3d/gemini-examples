# The "GDI\_periodic\_lowres" Example

This example shows an application of the GEMINI model to simulate gradient-drift instability in the 3D box.  The y-direction (x3) is taken to be periodic so as to accommodate a density patch that is elongated in that direction.  This particular setup tries to create the smallest (most efficient) grid possible that will allow GDI to be sensibly modeled.  The present form of this example runs comfortably on and 4-8 core workstation.

## Running this example

1. Before attempting to run this example you will need to do a full GEMINI installation as described in the README for the core [GEMINI](https://github.com/gemini3d/gemini) repository.  You will also need to install the [gemini-examples](https://github.com/gemini3d/gemini-examples) repository and the [mat_gemini](https://github.com/gemini3d/mat_gemini) repository.

2. Generate an equilibrium simulation for RISR.  The GDI\_periodic\_medres example is usually run with the [RISR_eq equilibrium simulation](./init/RISR_eq) as input which represents the ionospheric at nighttime above the Resolute Bay incoherent scatter radar location.

3. Define a new grid and upsample.  See the model\_setup\_interp.m script for an example of how to complete this step.  In essence this is taking a coarsely sampled equilibrium state and interpolating to up to a grid with fine resolution that can be used for a sensible turbulence simulation.  Be sure to adjust the paths so that they point to the place on your system where the simulation data are/will be stored.  This script specifically needs the path to the RISR_eq data and also needs the path where the upsampled initial conditions are to be stored.

4. Create a density enhancement for your simulation.  The model_setup_perturb.m script show an example of how to complete this step, which involves taking the upsampled initial condition and adding an unstable density gradient to it.  The parameters of the density enhancement can be specified by altering the script (see comments in the source code).  One must also include seed noise in order for the instability to be initiate.  Once this is done, you have a complete set of initial conditions for your simulations.  Be sure to change the path where these files are saved so that they are appropriate for the computer system you are running on.

5. Create boundary conditions.  GEMINI also requires boundary conditions on the electric field and particle precipitation.  In this simulation we are attempting to describe the polar cap and we do not specify the precipitation input at all in the config.ini, in which case the model will set it to some very small value (possibly zero - see source code for details).  A background electric field is required for GDI to grow and this is set in the "Efield_BCs.m" script.  The background field x and y components are set in the script as well as the potential boundary condition, which is taken to be zero current in order to allow the instability to not short through the magnetosphere.

6. Update the config.nml to work with your filesystem. The config.nml file must contain the full path to your simulation grid and your initial conditions.  It must also contain the path (directory) where the electric field input files are kept (and the precipitation files too, which aren't used here).

7. run the simulation:

```sh
mpirun -np 8 ./gemini.bin path/GDI_periodic_medres/config.ini path/outputdirectory/ -manual_grid 4 2
```
