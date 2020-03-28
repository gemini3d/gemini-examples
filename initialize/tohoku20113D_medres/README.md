# The tohoku20113D\_medres Example

This example simulates ionospheric response to the M 9.0 2011 Tohoku earthquake occurring off of the coast of Japan.  It illustrates the use of neutral wave data input from another model (MAGIC in the cases that we've published), and takes approximately 36-48 hours to run on a 8 core machine (something more recent than Haswell vintage).  The default grid size is 384 x 144 x 144 (~7M grid points), but can be adjusted arbitrarily (within CPU and memory constraints).  

## Running this example

0)  Before attempting to run this example you will need to do a full GEMINI installation as described in the README for the core [GEMINI](https://github.com/gemini3d/GEMINI) repository.  You will also need to install the [GEMINI-examples](https://github.com/gemini3d/GEMINI-examples) repository and the [gemini-matlab](https://github.com/gemini3d/gemini-matlab) repository.  

1)  Either obtain equilibrium data from its repository [TBD]() or run the Tohoku equilibrium simulation found [https://github.com/gemini3d/GEMINI-examples/tree/master/initialize/tohoku20113D_eq](https://github.com/gemini3d/GEMINI-examples/tree/master/initialize/tohoku20113D_eq) to recompute initial conditions for this simulations example.  

2)  Download the neutral simulation data from its repository [TBD]().  Note that these data are from the MAGIC compressible atmospheric model (described in [Zettergren and Snively (2015)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2015JA021116)) and were used for the 3D simulation of ionospheric responses to the Tohoku event published in [Zettergren and Snively (2019)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2018GL081569?casa_token=g2l3MOiyg4YAAAAA%3AUygvgBFrbj0ffiFzZuEhogWuAODDE3HH3RohpCDy5BvflfBqK_58jjy1kTe8EsAup9OxZBYNr34OpM5t)

3)  Change the paths for the (a) size file, (b) grid file, (c) initial conditions file, and (d) neutral input data directory in the config.ini (or config.nml) file so that they point to where the input data are stored on your computer.  

4)  Run the simulation using:

``` cd <GEMINI directory>/build ```
``` mpirun -np 8 ./gemini.bin <GEMINI-examples dir>/initialize/tohoku20113D_medres/config.ini <output directory> ```

5)  Once the simulation is done the results can be plotted by opening matlab and setting the paths by:

``` cd <gemini-matlab directory> ```

``` setup ```

``` cd vis ```

``` plotall('<output direcotry>',{'png'}) ```

This will print the plots to .png files within the output directory.  

6)  To compute TEC perturbations from the simulation output you first need a control simulation so that the background TEC can be subtracted out.  The easiest way to do this is to

7)  A MATLAB script for computing TEC perturbations is included in the [gemini-matlab respository](https://github.com/gemini3d/gemini-matlab), specifically [here](https://github.com/gemini3d/gemini-matlab/blob/master/matlab/vis/TECcalc.m).


