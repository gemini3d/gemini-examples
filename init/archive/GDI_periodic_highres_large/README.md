# The GDI_periodic_highres_large example

This example is based loosely on that published in Deshpande and Zettergren, 2019 and can be altered to mimic patches of different size, gradient, etc. with diferent types of seeding.

The background density (given from the equilibrium simulation RISR_eq) is about 2.1e10.  Noise is added to this and it is scaled up so that the max density is about 6.9e11 with an 8:1 patch to background density ratio.

May want to consider adding a stretched grid in x2 to eliminate potential boundary affects on the simulations.

The grid is such that it can be divided into 20x18 subdomains so that it runs well on VEGA.  This is results in a grid of 64x1540x1062 - just over 100M grid points.

The initial gradient scale length set up by the input scripts is:
