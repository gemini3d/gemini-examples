# "*\_periodic\_lowres" examples

These examples show application of the GEMINI model to simulate various interchange instabilities (gradient-drift, Kelvin-Helmholtz, and gravitational Rayleigh-Taylor) in a 3D box.
The y-direction (x3) is taken to be periodic so as to facilitate a reduction in domain size; i.e.  to create the smallest (most efficient) grid possible that will allow the most basic features of these instabilities to be modeled.

These examples run on and 4 core laptop with 16 GB memory and ~4 GB free storage.
Each simulation takes about ~30 minutes to complete.

This exercise builds familiarity with using the command line / terminal, filesystem hierarchy, and the Python programming language using the IPython interactive interpreter.

## Python setup

If you don't have an existing Python installation, we suggest
[Miniconda](https://docs.anaconda.com/free/miniconda/index.html#quick-command-line-install).
Install a few prerequisites needed for PyGemini like:

```sh
conda install numpy scipy matplotlib xarray h5py ipython
```

## Installation

Throughout this example, we'll assumed you're working under directory $HOME/gemini.
This notation works across operating systems (Windows, Linux, macOS).
You can use "~/gemini" as a shorthand notation.
On Windows, please use PowerShell (built into all Windows computers), not Command Prompt.
On macOS or Linux, the default Terminal shell will work.

```sh
mkdir $HOME/gemini

cd $HOME/gemini
```

You will also need the files in this directory to set up the three simulations; these are most easily obtained by cloning the
[gemini-examples](https://github.com/gemini3d/gemini-examples) repository.

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

cmake -S gemini3d -B gemini3d/build

cmake --build gemini3d/build -j
```

Finally, you will need the PyGemini front- and back- end scripting for prepping input data and plotting; this requires an existing Python installation.

```sh
git clone https://github.com/gemini3d/pygemini

pip install -e ./pygemini
```

## Creating input data for simulation

Initial conditions for these simulations for a specific grid size, etc., are created from existing, low-resolution "equilibrium" simulations.
These could be manually downloaded from
[Zenodo](https://zenodo.org/records/11509797) (archival, slower)
or
[Dropbox](https://www.dropbox.com/scl/fo/d2b0so28oom1cfr3jlzhz/AI1l23BNLSrqcrtqru4lEDo?rlkey=t6ko7zy6xfmkw9rpmpzh2yqjt&e=1&st=yziwgr4p&dl=0) (faster, but might have been removed).

You can use Curl from the command line as below, or click the links above.

```sh
curl -o cedar2024_gemini_examples.zip -L "https://zenodo.org/records/11509797/files/CEDAR2024_examples.zip?download=1"
```

Extract the ZIP file to wherever you like.
This can be done from the command line with any one of the following commands:

```sh
unzip cedar2024_gemini_examples.zip
# or
tar xf cedar2024_gemini_examples.zip
# or
cmake -E tar xf cedar2024_gemini_examples.zip
```

The two directories thereby extracted are "ESF_CEDAR2024" and "ESF_eq_CEDAR2024".

Edit the `eq_dir` variable in the `config.nml` file for whichever example you want to run.
Make `eq_dir` point to the filesystem directory where you have extracted the equilibrium data .zip file.

Once these are obtained one can run the setup for one of the instability simulations.
Here we will use the ESF example.

Run from Python interpreter like:

```python
import gemini3d.model

gemini3d.model.setup("~/gemini/gemini-examples/init/CEDAR2024/ESF_periodic_lowres/config.nml", "~/gemini/ESF_periodic")
```

This will generate grid, initial conditions, and boundary conditions information that the core GEMINI model will use for its simulation.


## Running the simulation

Navigate to the directory where the code was built and run it on the input data created.

```sh
cd $HOME/gemini/gemini3d/build/

mpirun -np 4 ./gemini.bin place/to/put/simulation/data
```


## Gridding and plotting the output

Once the simulation has been run the
[init/CEDAR2024/visualization.py](./init/CEDAR2024/visualization.py)
script shows how you can form datacubes (i.e. regularly gridded output in lat/lon) and then plot them.
