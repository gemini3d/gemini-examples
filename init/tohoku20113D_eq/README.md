# The "tohoku20113D\_eq", initial condition generation simulation

This example simulates the background, equilibrium ionospheric state for the M 9.0 2011 Tohoku earthquake occurring off of the coast of Japan.  The purpose of this run is to take an initial, arbitrary state and then run the model 24 hours to equilibrium.  This equilibrium state can then be used as the input for a higher resolution simulation with an applied disturbance.



## Running this example

0)  Before attempting to run this example you will need to do a full GEMINI installation as described in the README for the core [GEMINI](https://github.com/gemini3d/gemini3d) repository.  You will also need to install the [GEMINI-examples](https://github.com/gemini3d/GEMINI-examples) repository and the [mat_gemini](https://github.com/gemini3d/mat_gemini) repository.

1)  Run the MATLAB script to set up some initial conditions (arbitrary) and store the grid, etc.,  for the simulation

```sh
cd gemini-examples
setup
model_setup('init/tohoku20113D_eq')
```

2)  Now that the equilibrium simulation input data exist, start the run which will compute the desired equilibrium state, from Matlab:

```matlab
gemini_run('init/tohoku20113D_eq', '~/simulations/tohuku')
```
