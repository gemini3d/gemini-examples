# New Mexico 10t Explosion Simulation Case

This directory contains setup for 10t explosion at EMRTC in Socorro, NM, May 2024.  There are two modes of running this case:

1.  with self-consistent chemistry and vertical transport
2.  with specified density simulation

Each of these modes can be used with a different date by following the setup steps described below.  

## Self-consistent chemistry simulation

The self-consistent setup requires generating an equilbrium state (```./Equil```), adjusting the state to mimic the observations and letting it settle (```./Staging```).  These first two steps can be run through the regular GEMINI model.  Then the simulation with the acoustic waves can be run through through trees-GEMINI (```./Disturb```)

## Specified density simulation

In this case, one can omit the "Staging" step since the density is fixed and chemistry disabled (so no need to allow the profile to settle).  Setup requires generating an equilbrium state (```./Equil```), and then applied the specified density via ```Specified_ne```.  

## Density profile

The density profile is stored in plain text format in ```fp_profile.txt``` (as plasma frequency); ```perturb.py``` converts these into density and save them in a format amenable to initial conditions for GEMINI.  