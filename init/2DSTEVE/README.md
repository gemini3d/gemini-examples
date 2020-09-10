# The "2DSTEVE" Example

This example is an efficient 2D simulation of a STEVE auroral features driven by strong field-aligned currents.  The heating in this simulation is quite intense; similar to what has been observed from SWARM.

## Running this example

0. Before attempting to run this example you will need to do a full GEMINI installation as described in the README for the core [GEMINI](https://github.com/gemini3d/gemini3d) repository.  You will also need to install the [GEMINI-examples](https://github.com/gemini3d/GEMINI-examples) repository and the [mat_gemini](https://github.com/gemini3d/mat_gemini) repository.

1. Either obtain equilibrium data from one of the model developer or by running the 2Dtest_eq equilibrium simulation found at [init/tohoku20113D_eq](./init/2Dtest_eq).

2. Define a new grid and interpolate up.  See the model_setup_interp.m script for an example of how to complete this step.  Be sure to adjust the paths in this script to match your machine's setup.

3. Change the paths for the (a) size file, (b) grid file, (c) initial conditions file, and (d) neutral input data directory in the config.ini (or config.nml) file so that they point to where the input data are stored on your computer.

4. Run the simulation from Matlab:

    ```matlab
    cd gemini-examples/init/2DSTEVE

    gemini3d.gemini_run('~/sims/steve')
    ```

5. Once the simulation is done the results can be plotted by opening matlab and setting the paths by:

    ```
    gemini3d.vis.plotall('~/sims/steve', 'png')
    ```
