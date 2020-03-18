# The tohoku20113D\_medres Example

This example simulates ionospheric response to the M 9.0 2011 Tohoku earthquake occurring off of the coast of Japan.  It illustrates the use of neutral wave data input from another model (MAGIC in the cases that we've published), and takes approximately 36-48 hours to run on a 4-8 core machine (something more recent than Haswell vintage).  The default grid size is 384 x 144 x 144 (~7M grid points), but can be adjusted arbitrarily (within CPU and memory constraints).  

## Running this example

0)  Before attempting to run this example you will need to do a full GEMINI installation as described in the README for the [core GEMINI model respository](https://github.com/gemini3d/GEMINI).  

1)  Either obtain equilibrium data from its repository [TBD]() or run the Tohoku equilibrium simulation found [https://github.com/gemini3d/GEMINI-examples/tree/master/initialize/tohoku20113D_eq](https://github.com/gemini3d/GEMINI-examples/tree/master/initialize/tohoku20113D_eq) to recompute initial conditions for this simulations example.  

2)  Obtain the neutral simulation data from its repository [TBD]().  Note that these data are from the MAGIC compressible atmospheric model (described in [Zettergren and Snively (2015)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1002/2015JA021116)) and were used for the 3D simulation of ionospheric responses to the Tohoku event published in [Zettergren and Snively (2019)](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2018GL081569?casa_token=g2l3MOiyg4YAAAAA%3AUygvgBFrbj0ffiFzZuEhogWuAODDE3HH3RohpCDy5BvflfBqK_58jjy1kTe8EsAup9OxZBYNr34OpM5t)

3)  


