# The "tohoku20113D\_medres" Example

This example simulates ionospheric response to the M 9.0 2011 Tohoku earthquake occurring off of the coast of Japan.

It illustrates the use of neutral wave data input from another model (MAGIC in the cases that we've published), and takes approximately 36-48 hours to run on a 8 core machine (something more recent than Haswell vintage).  The code scales approximately linearly so for a 4 core machine the runtime will be nearly twice as long as for 8 cores, for 16 cores it will be half.  The default grid size is 384 x 144 x 144 (~7M grid points), but can be adjusted arbitrarily (within CPU and memory constraints).  A machine requires approximately X GB ram to run the simulation and about 300 GB disk space to store the output data.

## Running this example

1. Before attempting to run this example you will need to do a full GEMINI installation as described in the README for the core [GEMINI](https://github.com/gemini3d/GEMINI) repository.  You will also need to install the [GEMINI-examples](https://github.com/gemini3d/GEMINI-examples) repository and the [mat_gemini](https://github.com/gemini3d/mat_gemini) repository.

2. Either obtain equilibrium data (a) from its repository [TBD]() or (b) run the Tohoku equilibrium simulation found [https://github.com/gemini3d/GEMINI-examples/tree/master/initialize/tohoku20113D_eq](https://github.com/gemini3d/GEMINI-examples/tree/master/initialize/tohoku20113D_eq) (see associated README for instruction) to recompute initial conditions for this simulation example.

3. Define a new grid and interpolate up.  See the model_setup_interp.m script for an example of how to complete this step.  Be sure to adjust the paths in this script to match your machine's setup.

4. Download the neutral simulation data from its Zenodo repository [linked here](www.).  Note that these data are from the MAGIC compressible atmospheric model (described in [Zettergren and Snively (2015)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2015JA021116)) and were used for the 3D simulation of ionospheric responses to the Tohoku event published in [Zettergren and Snively (2019)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2018GL081569?casa_token=g2l3MOiyg4YAAAAA%3AUygvgBFrbj0ffiFzZuEhogWuAODDE3HH3RohpCDy5BvflfBqK_58jjy1kTe8EsAup9OxZBYNr34OpM5t).  These input data occupy about 40 GB of disk space.

5. Change the paths for the (a) size file, (b) grid file, (c) initial conditions file, and (d) neutral input data directory in the config.ini (or config.nml) file so that they point to where the input data are stored on your computer.

6. Run the simulation using:

```
cd <GEMINI directory>/build
mpirun -np 8 ./gemini.bin <GEMINI-examples dir>/initialize/tohoku20113D_medres/config.ini <output directory>/
```

7. Once the simulation is done the results can be plotted by opening matlab and setting the paths by:

```
cd <mat_gemini directory>
setup
cd vis
plotall('<output direcotry>',{'png'})
```

This will print the plots to .png files within the output directory.  The zenodo archive for this example contains movies with which you can compare your results to insure you have correctly built and run everything.

8. To compute TEC perturbations from the simulation output you first need a control simulation so that the background TEC can be subtracted out.  The simplest way to do this is to rerun the GEMINI code but use the control input config file:

```
mpirun -np 8 ./gemini.bin <GEMINI-examples dir>/initialize/tohoku20113D_medres/config.ini.control <output directory>_control/
```

9. A MATLAB script for computing TEC perturbations is included in the [mat_gemini respository](https://github.com/gemini3d/mat_gemini), specifically [here](https://github.com/gemini3d/mat_gemini/blob/master/matlab/vis/TECcalc.m).  To run this script, you will need to edit it to point to you simulation output directories, i.e. these lines:

```
simname='<simulation dir name>/';
simname_control='<control simulation dir name>/';
basedir='/media/data/zettergm/simulations/';
```

Note the forward slash "/" at the end of the simulation names.  Then open MATLAB and run the script:

```
cd <mat_gemini directory>
setup
cd vis
TECcalc
```
