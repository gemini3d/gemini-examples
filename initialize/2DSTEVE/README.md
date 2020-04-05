# The "2DSTEVE" Example

This example is an efficient 2D simulation of a STEVE auroral features driven by strong field-aligned currents.  The heating in this simulation is quite intense; similar to what has been observed from SWARM.  

## Running this example

0)  Before attempting to run this example you will need to do a full GEMINI installation as described in the README for the core [GEMINI](https://github.com/gemini3d/GEMINI) repository.  You will also need to install the [GEMINI-examples](https://github.com/gemini3d/GEMINI-examples) repository and the [gemini-matlab](https://github.com/gemini3d/gemini-matlab) repository.  

1)  Either obtain equilibrium data from one of the model developer or by running the 2Dtest_eq equilibrium simulation found at [https://github.com/gemini3d/GEMINI-examples/tree/master/initialize/tohoku20113D_eq](https://github.com/gemini3d/GEMINI-examples/tree/master/initialize/2Dtest_eq).

2)  Define a new grid and interpolate up.  See the model_setup_interp.m script for an example of how to complete this step.  Be sure to adjust the paths in this script to match your machine's setup.   

3)  Change the paths for the (a) size file, (b) grid file, (c) initial conditions file, and (d) neutral input data directory in the config.ini (or config.nml) file so that they point to where the input data are stored on your computer.  

4)  Run the simulation using:

``` 
cd <GEMINI directory>/build 
mpirun -np 8 ./gemini.bin <GEMINI-examples dir>/initialize/2DSTEVE/config.ini <output directory>/ 
```

5)  Once the simulation is done the results can be plotted by opening matlab and setting the paths by:

``` 
cd <gemini-matlab directory>
setup
cd vis
plotall('<output direcotry>',{'png'})
```