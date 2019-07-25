# The KHI_periodic_medres example

This example simulates ionospheric Kelvin-Helmholtz instability.  

## Running this example

See the GDI_periodic_medres example README for details on how to set up the simulation.  This particular example is very similar as it does not require precipitation input; potential boundary condtions are required and set through a script contained in this directory.  

Initial density perturbations are set according to the formulation in Keskinen 1988 see model_setup_perturb.m - this script has several adjustable parameters that can be used to set the density variations across the shear.  The Efield_BCS.m script should be adjusted so that it uses the same input parameters so that the initial state represents an ionospheric equilibrium.  


