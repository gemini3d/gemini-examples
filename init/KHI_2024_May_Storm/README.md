# KHI 2024 May storm ("Gannon Storm")

This example simulates ionospheric Kelvin-Helmholtz instability occurring in what appears to be the equatorward trough boundary in the TEC data.

## Running this example

The configuration for this simulation uses a specified density profile which can be set using a Chapman profile or perhaps ionosonde data during the storm.  It further assumes classical KHI setup for the ionosphere (i.e. according to the linear theory outlined in Keskinen, 1988).  Parameters of the density profile and drift setup can be set in ```perturb.py```.  Once these have been set one can run:

```python
import gemini3d.model
gemini3d.model.setup("./config.nml","~/simulations/2024_May_Storm_KHI")
```
which will generate the input files for the simulation.  

While either the full version of GEMINI or the density/potential only version can be run with this case, it makes the most sense to probably run with the density and potential solutions to avoid settling (i.e. unwanted transient flows) from whatever profile the user specifies:

```bash
mpirun -np 8 ./gemini.denspot.bin ~/simulations/2024_May_Storm_KHI
```

