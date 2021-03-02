# The "tohoku20113D\_eq", initial condition generation simulation

This example simulates the background, equilibrium ionospheric state for the M 9.0 2011 Tohoku earthquake occurring off of the coast of Japan.  The purpose of this run is to take an initial, arbitrary state and then run the model 24 hours to equilibrium.  This equilibrium state can then be used as the input for a higher resolution simulation with an applied disturbance.



## Running this example

Before attempting to run this example you will need to do a full GEMINI installation as described in the README for the core
[GEMINI](https://github.com/gemini3d/gemini3d)
repository.
You will also need to install the
[GEMINI-examples](https://github.com/gemini3d/GEMINI-examples)
repository and the
[mat_gemini](https://github.com/gemini3d/mat_gemini)
repository.

Select the MATLAB script to set up some initial conditions (arbitrary) and store the grid, etc.,  for the simulation

```sh
cd gemini-examples/ci/equilibrium/tohoku3d_eq
```

Create equilibrium simulation input data and compute the desired equilibrium state from Matlab:

```matlab
gemini3d.model.setup('.', '~/sims/tohoku3d_eq')
```

from the terminal gemini3d/build/ directory

```sh
./gemini3d.run ~/sims/tohoku3d_eq
```
