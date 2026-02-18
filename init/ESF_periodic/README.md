# Equatorial Spread F Simulation Examples

These directories contain various configurations for different types of plasma bubble simulations including:  

1.  An equilibrium setup for running a narrow (in longitude region):  ```./Eq```
2.  An equilibrium setup for wider regions such as would be needed to study coupling with AGWs:  ```./Eq_Dneu```
3.  A setup that runs a bubble simulation with noise-like seed perturbations:  ```./Disturb_Noise```
4.  Setup using a Gaussian density perturbation in the middle of the grid:  ```./Disturb_Gaussian```
5.  Setup for perturbing the density using incident AGWs:  ```./Disturb_Dneu```
6.  Setup for initializing a bubble simulation from the last frame of an existing simulation (presumably perturbed by some custom user-defined simluation process):  ```Disturb_Custom```

A basic script to plot the results from one of the Disturbance simulations in included:  ```./visualization.py```.

# Caveats

We have found in many cases that the code will achieve extremely low densities (< 1 per cubic meter) in regions where the bubbles are forming leading to runaway electron temperatures.  This can be avoided by including nighttime photoionization (e.g. scattered airglow) or enforcing a minimum density (~1000 per cubic meter).  