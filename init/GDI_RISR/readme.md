# RISR Data-driven Simulation Example

This directory contains setup files for running GEMINI using inputs from the SRI AMISR volumetric interpolation code.  Specifically this example is meant to model a finite patch, but could be used to set up other types of structures, e.g., related to auroral arcs.  

To perform a simulation using data inputs there are three main steps:

1. (equilibrium run) generate equilbrium data corresponding to a steady-state ionosphere for the date, time, and location of interest
2. (staging run) apply data and allow the simulation to settle from the initial conditions *imposed* on it.  GEMINI needs to begin from an equilibrium state consistent with its own set of equations and arbitrarily applying data to the initial conditions can cause unphysical transients.  The solution is to allow these transients to run out over ~10 minutes so that the model can determine its equilibrium roughly consistent with data inputs.  
3. (disturbance run) Here the staged/settled results from the staging run are used as initial conditions for a run where addition energy inputs (e.g. convection) are applied.  

It is possible that step 1 could be omitted and that one could start a staging run directly from the data, but this is not recommended since one also needs initial temperatures and drifts and these are not always available from the ISR data.  


## 1.  Equilibrium Simulation

Generally speaking equilibrium runs will proceed for some amount of time with no energy inputs other than solar forcing in order to allow the ionosphere to settle from some arbitrary initial state generated from ```pygemini``` or ```mat_gemini```.  The resolution of such a simulation is usually very low since there are not structured initial conditions or inputs, and the simulation is usually run for 24 hours though this need not be the case, e.g., if one wants to generate an initial equilibrium density other than the one naturally occurring due to solar forcing and corotation of plasma with the earth.  

The most important thing to set for the equilbrium run is to make sure the domain is large enough so that the results can be interpolated onto the domain of interest for the staging and disturbance simulations.  The equilbrium simulation domain will need to be *larger* than the domain of the disturbance simulation due to the way ghost cells are handled internally in the grid generation code.  

As mentioned the resolution is not that important for equilibrium simulations; however, it must at least be good enough to not produce interpolation artifacts when one samples the equilibrium simluation output onto a higher-resolution grid for the staging and disturbance simulations.  The appropriate resolution is often difficult to determine *a priori* so one may need to experiment with a few different cell sizes.  Usually this is not problematic since these simulations often take less than an hour to run due to the overall small number of cells.  

An example input config file for an equilbrium simulation is shown below:  

```
&base
ymd = 2013,2,19               ! year, month, day
UTsec0 = 18000.0              ! start time in UT seconds
tdur = 86400.0                  ! duration of simulation in seconds
dtout = 1800.0                  ! how often to do output
activ = 150.0,150.0,50.0      ! f107a,f107,Ap
tcfl = 0.9                    ! target cfl number
Teinf = 1500.0                ! exospheric electron temperature
/

&setup
glat = 75.6975
glon = 265.1678
xdist = 3000e3             ! eastward distance (meters)
ydist = 3000e3             ! northward distance (meters)
lxp = 64
lyp = 64
Bincl = 90
nmf = 5e11
nme = 2e11
alt_min = 80e3
alt_max = 1000e3
alt_scale = 50e3, 45e3, 400e3, 150e3
/

&flags
potsolve = 0      ! solve electrodynamics:   0 - no; 1 - electrostatic; 2 - inductive
flagoutput = 1
/

&files
indat_size = 'inputs/simsize.h5'
indat_grid = 'inputs/simgrid.h5'
indat_file = 'inputs/initial_conditions.h5'
/

```



## 2.  Staging Simulation

The staging simulation takes an upsampled initial state from the equilibrium simulations and applies ISR data to this state in order to initial some observed structures and then allow them to settle.  An example input file for the staging simulation is shown below.  

```
&base
ymd = 2013,2,20               ! year, month, day
UTsec0 = 18000.0              ! start time in UT seconds
tdur = 600.0                  ! duration of simulation in seconds
dtout = 60.0                   ! how often to do file output
activ = 150.0,150.0,50.0      ! f107a,f107,Ap
tcfl = 0.9                    ! target cfl number
Teinf = 1500.0                ! exospheric electron temperature
/

&setup
glat = 75.6975
glon = 265.1678
xdist = 1490e3                ! eastward distance (meters), including a large low-res buffer for solvers
ydist = 1490e3                ! northward distance (meters)
lxp = 384
!lyp = 344
lyp = 100
x2parms = 348e3,4.e3,15e3,50e3
x3parms = 348e3,4.e3,15e3,50e3
Bincl = 90
alt_min = 80e3
alt_max = 975e3
alt_scale = 50e3, 45e3, 400e3, 150e3 ! super coarse along the field line
Eyit = 0e-3
eq_dir = '~/simulations/raid/GDI_RISR_MR_staging/'
setup_functions = 'perturb_file'
/

&flags
potsolve = 1      ! solve electrodynamics:   0 - no; 1 - electrostatic; 2 - inductive
flagperiodic = 0
flagoutput = 2
/

&files
indat_size = 'inputs/simsize.h5'
indat_grid = 'inputs/simgrid.h5'
indat_file = 'inputs/initial_conditions.h5'
/

&efield
dtE0 = 10.0                         ! time step between electric field file inputs
E0_dir = 'test_data/test3d_glow/inputs/Efield_inputs/'
/

&Jpar
flagJpar=.false.
/

&precip_BG
PhiWBG=1e-3
W0BG=3e3
/

&capacitance
flagcap=1       !use inertial capacitance? 0 - set all to zero, 1 - use ionosphere to compute, 2 - add a magnetospheric part
magcap=0.0
/

&milestone
mcadence=6
/

&lagrangian
flaglagrangian=.true.
/

&diamagnetic
flagdiamagnetic=.true.
/
```

The staging simulation need not be done at the same resolution as the disturbance; it simply needs to be able to resolve variations in the data inputs.  Results can be interpolated up to a finer grid for the disturbance run.   This requirement is obviously dependent on the data inputs and will need to be adjusted according to the specific AMISR dataset used.  

The call to the setup function ```perturb_file``` contains all of the code to read in the AMISR data (filename required) and produce an interpolated version of the dataset on the GEMINI mesh.  The data interpolation is accomplished using the AMISR volumetric interpolation software [https://github.com/amisr/volumetricinterp](https://github.com/amisr/volumetricinterp).  For now parts of this repository are duplicated by eventually this needs to be properly included as a sub-repository for ```gemini-examples```.  




## 3.  Disturbance Simulation


The ```config.nml``` file for a disturbance simulation looks like the following:   

```
&base
ymd = 2013,2,20               ! year, month, day
UTsec0 = 18000.0              ! start time in UT seconds
tdur = 1800.0                  ! duration of simulation in seconds
dtout = 5.0                   ! how often to do file output
activ = 150.0,150.0,50.0      ! f107a,f107,Ap
tcfl = 0.9                    ! target cfl number
Teinf = 1500.0                ! exospheric electron temperature
/

&setup
glat = 75.6975
glon = 265.1678
xdist = 1490e3                ! eastward distance (meters), including a large low-res buffer for solvers
ydist = 1490e3                ! northward distance (meters)
lxp = 384
!lyp = 344
lyp = 100
x2parms = 348e3,1.e3,15e3,50e3
x3parms = 348e3,1.e3,15e3,50e3
Bincl = 90
alt_min = 80e3
alt_max = 975e3
alt_scale = 50e3, 45e3, 400e3, 150e3 ! super coarse along the field line
Eyit = -40e-3
eq_dir = '~/simulations/raid/GDI_RISR_MR_staging/'
setup_functions = 'gemini3d.model.Efield_BCs'
/

&flags
potsolve = 1      ! solve electrodynamics:   0 - no; 1 - electrostatic; 2 - inductive
flagperiodic = 0
flagoutput = 2
/

&files
indat_size = 'inputs/simsize.h5'
indat_grid = 'inputs/simgrid.h5'
indat_file = 'inputs/initial_conditions.h5'
/

&efield
dtE0 = 10.0                         ! time step between electric field file inputs
E0_dir = 'test_data/test3d_glow/inputs/Efield_inputs/'
/

&Jpar
flagJpar=.false.
/

&precip_BG
PhiWBG=1e-3
W0BG=3e3
/

&capacitance
flagcap=1       !use inertial capacitance? 0 - set all to zero, 1 - use ionosphere to compute, 2 - add a magnetospheric part
magcap=0.0
/

&milestone
mcadence=6
/

&lagrangian
flaglagrangian=.true.
/

&diamagnetic
flagdiamagnetic=.true.
/

```

The setup for the disturbance run is actually the most straightforward; this file tells the setup to interpolate the output from the staging simulations onto a new high-resolution grid for simulating instability and cascade.  



# Additional Notes

These simulations (finite patches) appear to be incredibly sensitive to ```degdist``` - the distance from the boundary where the high resolution part of the grid begins.  If you are seeing errors for MUMPS singular matrix or non-finite solution values try reducing this parameter.  The problem often arises when increasing the resolution; in these cases the degradation distance needs to (apparently) be smaller.  Some example *known working* configurations are listed here as a guide.  

```
1.  x2parms,x3parms = 248.0e3,0.75e3,15e3,50e3
2.  x2parms,x3parms = 348e3,1.e3,15e3,50e3
3.  x2parms,x3parms = 498.0e3,1.475e3,15e3,50e3

```

Note in particular how the higher resolution in the grid needs to be complemented with a larger high-resolution region (smaller first parameter, which is the distance from the boundary where the high-resolution region starts).  