# "*\_periodic\_lowres" examples

These examples show application of the GEMINI model to simulate various interchange instabilities (gradient-drift, Kelvin-Helmholtz, and gravitational Rayleigh-Taylor) in a 3D box.
The y-direction (x3) is taken to be periodic so as to facilitate a reduction in domain size; i.e.  to create the smallest (most efficient) grid possible that will allow the most basic features of these instabilities to be modeled.

These examples run on and 4 core laptop with 16 GB memory and ~4 GB free storage.  Each simulation takes about ~30 minutes to complete.


## Installation

You will also need the files in this directory to set up the three simulations; these are most easily obtained by cloning the [gemini-examples](https://github.com/gemini3d/gemini-examples) repository.

```sh
git clone https://github.com/gemini3d/gemini-examples
```

Alternatively one could simply copy the source files from the GitHub webpage.

Core GEMINI code installation details are covered in the
[GEMINI](https://github.com/gemini3d/gemini)
repository; he we provide an brief summary.
Once you have installed a compiler (gcc recommended), mpi implementation (openmpi recommended), and cmake you can pull the GEMINI repository, configure, and compile.

```sh
git clone https://github.com/gemini3d/gemini3d
cd gemini3d
cmake -B build
cmake --build build -j
```

Finally, you will need the PyGemini front- and back- end scripting for prepping input data and plotting; this requires an existing Python installation.

```sh
git clone https://github.com/gemini3d/pygemini
pip install -e ./pygemini
```

## Creating input data for simulation

Initial conditions for these simulations for a specific grid size, etc., are created from existing, low-resolution "equilibrium" simulations.  These can be downloaded here:  .

Make sure the `eq_dir` variable in the `config.nml` file for whichever example you want to run points to the place where you have downloaded the equilbrium data.

Once these are obtained one can run the setup for one of the instability simulations (here we will use the ESF example):

```sh
cd gemini-examples/init/CEDAR2024/ESF_periodic_lowres/
ipython
```

Once python has started you can run the setup scripts on the example you wish to simulate:

```python
import gemini3d.model
gemini3d.model.setup("./config.nml","place/to/put/simulation/data")
```

This will generate grid, initial conditions, and boundary conditions information that the core GEMINI model will use for its simulation


## Running the simulation

Navigate to the directory where the code was built and run it on the input data created.

```sh
cd gemini3d/build/
mpirun -np 4 ./gemini.denspot.bin place/to/put/simulation/data
```


## Gridding and plotting the output

Once the simulation has been run the visualization.py script shows how you can form datacubes (i.e. regularly gridded output in lat/lon) and then plot them.  The variable for the data directory ("direc") will need to be changed to "place/to/put/simulation/data/".
