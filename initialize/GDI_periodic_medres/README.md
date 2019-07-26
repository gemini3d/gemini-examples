# The GDI_periodic_medres example

This example shows an application of the GEMINI model to simulate gradient-drift instability in the 3D box.  The y-direction (x3) is taken to be periodic so as to accommodate a density patch that is elongated in that direction.  

## Running this example

### 1)  Generate an equilibrium simulation for RISR
GEMINI is a dynamic model - if you start it in an arbitrary state it will "ring" and take a while to settle into a equilibrium.  If one is not careful this can obscure physics of interest so the best approach is to initialize GEMINI using a steady state solution.  There is not good way to obtain such a solution except for to start the model from an arbitrary state and let it run for a very long time until it achieves equilbrium.  This would be an expensive thing to do except that the equilbrium state will have very little structure and so may be run at a very coarse resolution.  Often for a Cartesian grid with a limited lat/lon extent 64 x 20 x 20 is sufficient.  

The GDI_periodic_medres example is usually run with the RISR_eq equilibrium simulation as input which represents the ionospheric at nighttime above the Resolute Bay incoherent scatter radar location.  These equilibrium can be obtained from the developers or may be generated by running the RISR_eq example from the repo in order to generate these data.

### 2)  Define a new grid and interpolate up 

See the model_setup_interp.m script for an example of how to complete this step.  In essence this is taking a coarsely sampled equilibrium state and interpolating to up to a grid with fine resolution that can be used for a sensible turbulence simulation.  

Create a grid, Cartesian in this case, using the makegrid_cart3D.m script from the main GEMINI repository (https://github.com/gemini3d/GEMINI/)).  To see the GDI cascade well requires about 512 grid points in both the x and y directions (x2 and x3, respectively, in the model).  This is an expensive simulation and should be done on 16-256 cores and will take about 2 hours-2 days.  

Interpolate the data from the equilbruim run onto this new grid and shown by the example in the model_setup_interp.m script.  Be sure to adjust the paths so that they point to the place on your system where the simulation data are/will be stored.  This script specifically needs the path to the RISR_eq data and also needs the path where the upsampled initial conditions are to be stored.  

### 3)  Create a density enhancement for your simulation

The model_setup_perturb.m script show an example of how to complete this step, which involves taking the upsampled initial condition and adding an unstable density gradient to it.  The parameters of the density enhancement can be specified by altering the script (see comments in the source code).  One must also include seed noise in order for the instability to be initiate.  Once this is done, you have a complete set of initial conditions for your simulations.  Be sure to change the path where these files are saved so that they are appropriate for the computer system you are running on.  

### 4)  Create boundary conditions

GEMINI also requires boundary conditions on the electric field and particle precipitation.  In this simulation we are attempting to describe the polar cap and we do not specify the precipitation input at all in the config.ini, in which case the model will set it to some very small value (possibly zero - see source code for details).  A background electric field is required for GDI to grow and this is set in the "Efield_BCs.m" script.  The background field x and y components are set in the script as well as the potential boundary condition, which is taken to be zero current in order to allow the instability to not short through the magnetosphere.  

### 5)  Update the config.ini to work with your filesystem

The config.ini file must contain the full path to your simulation grid and your initial conditions.  It must also contain the path (directory) where the electric field input files are kept (and the precipitation files too, which aren't used here). 

### 6) Run the simulation

Our HPC uses the pbs queuing system; this particular run works reasonably well with 256 cores.  The basic mpirun command is:  

mpirun -np 256 ./gemini.bin path/GDI_periodic_medres/config.ini path/outputdirectory/ 16 16 

The latter two command line inputs are the size of the process grid, e.g. in this case the the 256 cores are divided into a set of 16x16 subdomains.  These are optional and you can leave them out if you want to code to try to decide on a process grid.  The algorithm for doing this is quite simple and may fail so it is always best to specify the process grid manually.  
 