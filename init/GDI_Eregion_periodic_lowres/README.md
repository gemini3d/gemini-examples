# The "GDI\_periodic\_lowres" Example

This example shows an application of the GEMINI model to simulate gradient-drift instability in the 3D box.  The y-direction (x3) is taken to be periodic so as to accommodate a density patch that is elongated in that direction.  This particular setup tries to create the smallest (most efficient) grid possible that will allow GDI to be sensibly modeled.  The present form of this example runs comfortably on and 4-8 core workstation.

## Running this example

Do a full GEMINI installation as described in the README for the core [GEMINI](https://github.com/gemini3d/gemini) repository.
You will also need to install the [gemini-examples](https://github.com/gemini3d/gemini-examples) repository and the
[mat_gemini](https://github.com/gemini3d/mat_gemini) repository.


NOTE: The following steps are all subsumed in "config.m" so you can skip ahead by from Matlab in this directory:

```matlab
cd gemini-examples/init/GDI_periodic_lowres

config
```

---

1. We have provided downloadable equilibrium simulation for RISR, as specified in config.nml:setup:eq_url.  The GDI\_periodic\_medres example is usually run with the [RISR_eq equilibrium simulation](./init/RISR_eq) as input which represents the ionospheric at nighttime above the Resolute Bay incoherent scatter radar location--but you don't have to do this since this example auto-downloads.

2. The config.nml defines a new grid and the model_setup() upsamples the downloaded equilibrium data.  This is taking a coarsely sampled equilibrium state and interpolating to up to a grid with fine resolution that can be used for a sensible turbulence simulation.

3. The perturb.m function is specified in config.nml:setup:setup_functions to create a density enhancement for your simulation. This involves taking the upsampled initial condition and adding an unstable density gradient to it.  The parameters of the density enhancement can be specified by altering the script (see comments in the source code).  One must also include seed noise in order for the instability to be initiate.  Once this is done, you have a complete set of initial conditions for your simulations.

4. Create boundary conditions.  GEMINI also requires boundary conditions on the electric field and particle precipitation.  In this simulation we are attempting to describe the polar cap and we do not specify the precipitation input at all in the config.nml, in which case the model will set it to some very small value.  A background electric field is required for GDI to grow and this is set by the config.nml:setup:setup_functions:gemini3d.model.Efield_BCs function.  The background field x and y components are set in the script as well as the potential boundary condition, which is taken to be zero current in order to allow the instability to not short through the magnetosphere.

5. Since config.nml can use relative paths to simulation grid, initial conditions, electric field and the precipitation files if used. Absolute path can also be used if desired, but this often is not necessary. Relative paths can make it easier to share scripts and config files.

6. run the simulation from Matlab:

    ```matlab
    out_dir = '~/sims/gdi_periodic_lowres'

    gemini3d.run(out_dir)
    ```

8. plot the simulation outputs (saved as PNG files under <output_dir>/plots)

    ```matlab
    gemini3d.plot(out_dir, 'png')
    ```
