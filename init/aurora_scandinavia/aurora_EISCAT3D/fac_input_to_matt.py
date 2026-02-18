#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Aug 21 14:28:53 2023

@author: jone

Function fac_input() provide FAC in units of A/m2 based on analyrical expressions, from
inpur arguments (time, mlon, mlat). The other functions are helper functions.
A coefficient file fac_input_coefs.h5 is also needed, and should be located in 
same directory as this file. Use example is shown at the end of the script.

"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd


def mlat_to_latdist(mlat, mlat0=67.5163):
    """
    Function that return the spatial x-argument to be used in Fourier representation
    of FAC from the fitted coefficients.

    Parameters
    ----------
    mlat : int/float or array-like
        magnetic latitude in degreed (use centered dipole in GEMINI) to convert
    mlat0 : float, optional
        the mlat location corresponding to x=0. Found using gglat.mlat.median()
        from Simons SCW event.

    Returns
    -------
    x argument corresponding to mlat, in units of km.

    """
    return (mlat - mlat0) * 111


def lat_fac(mlat, L=7628.888, scaling=10):
    """
    Return the FAC at input mlat location, only from the latitudinal contribution

    Parameters
    ----------
    mlat : int/float or array-like
        input locations in degrees, centered dipole coordinates (magnetic)
    L : float, optional
        The width of the domain used in fitting Fourier series. Must be the same
        as the L used to estimate the coefficients.
    scaling : int/float
        The amplitude coefficients are multiplied by this number to scale the results.
        The output from the AMPERE inversion from Simon results in very weak currents,
        typically ~0.1 muA/m2, which is unrealistic when going to finer scales.
        This keyword modifies this.

    Returns
    -------
    FAC [A/m2] from latitude profile only, at input locations.

    """

    if type(mlat) == int or type(mlat) == float:
        mlat = np.array([mlat])
    x = mlat_to_latdist(mlat)
    B_analytical = np.zeros(x.shape)
    current_analytical = np.zeros(x.shape)
    mu0 = 4 * np.pi * 10 ** (-7)

    # Read coeficient file:
    df = pd.read_hdf("fac_input_coefs.h5")
    N = df.shape[0] - 1
    amp_coef = df.amplitude.values * scaling  #
    phase_coef = df.phase.values

    for n in np.arange(0, N + 1):
        B_analytical = +B_analytical + amp_coef[n] * (
            np.cos(phase_coef[n]) * np.cos(2 * np.pi * n * x / L)
            + np.sin(phase_coef[n]) * np.sin(2 * np.pi * n * x / L)
        )
        current_analytical = +current_analytical + 2 * np.pi * n / (L * 1000 * mu0) * amp_coef[
            n
        ] * (
            np.sin(phase_coef[n]) * np.cos(2 * np.pi * n * x / L)
            - np.cos(phase_coef[n]) * np.sin(2 * np.pi * n * x / L)
        )
    g = np.exp(
        -((mlat - 70) ** 4) / (2 * 45**2)
    )  # Function that will make the ends go to 0 for the current
    current_analytical = current_analytical * g

    return current_analytical


def lon_fac(mlon, centerlon=105, width=90):
    """
    Function that return the longitude modulation of the FAC, based on a sine wave
    with a period of width degrees, centered around centerlon.

    Parameters
    ----------
    mlon : int/float or array-like
        magnetic longitude in degrees (use centered dipole in GEMINI) to convert
    centerlon : float, optional
        the mlon location in degrees corresponding to x=0.
    width : the width (in degrees) of a full period of the sine wave in longitude
        modulation

    Returns
    -------
    mlon modulation factor for FAC, in [-1,1].

    """
    k = 360 / width
    sine_part = np.sin(k * np.radians(mlon - centerlon))

    # We make the function decay less rapid toward zero by introducing this exp function
    # Note that this make the max amplitude reduce by typically 25%
    exp_part = np.exp(-((mlon - centerlon) ** 4) / (2 * 690**2))

    combined = sine_part * exp_part
    return combined

    # mlon = np.arange(centerlon-45,centerlon+45,1)


# plt.plot(mlon,np.sin(k*np.radians(mlon-centerlon)))
# np.sin(k*np.radians(mlon-centerlon))


def temp_fac(t, duration=200, sigmat=20):
    """
    Compute the temporal part of the FAC value, based on a Gaussian.

    Parameters
    ----------
    t : int/float or array-like
        Time in minutes.
    duration : int/float, optional
        Duration of modulation in units of minutes. The default is 200 min.
    sigmat : int/float, optional
        The sigma of Gaussian modulation, in minutes. The default is 20 min.

    Returns
    -------
    The Gaussian modulation factor for the input time.
    """

    return np.exp(-((t - 2 * sigmat) ** 2) / (2 * sigmat**2))


#    return np.exp(-(t)**2/(2*sigmat**2))


def fac_input(
    t, mlon, mlat, duration=200, sigmat=20, centerlon=105, width=90, L=7628.888, scaling=10
):
    """
    Return the FAC input in A/m2 at given time [minutes], mlon, mlat [in degrees]

    Parameters
    ----------
    t : int/float
        time in minutes.
    mlon : int/float or array-like
        input magnetic longitude in degrees.
    mlat : int/float or array-like
        input magnetic latitude in degrees.
    duration : int/float, optional
        Duration of modulation in units of minutes. The default is 200 min.
    sigmat : int/float, optional
        The sigma of Gaussian modulation, in minutes. The default is 20 min.
    centerlon : float, optional
        the mlon location in degrees corresponding to x=0.
    width : the width (in degrees) of a full period of the sine wave in longitude
        modulation
    L : float, optional
        The width of the domain used in fitting Fourier series. Must be the same
        as the L used to estimate the coefficients.
    scaling : int/float
        The amplitude coefficients are multiplied by this number to scale the results.
        The output from the AMPERE inversion from Simon results in very weak currents,
        typically ~0.1 muA/m2, which is unrealistic when going to finer scales.
        This keyword modifies this.

    Returns
    -------
    FAC at input time/location in A/m2.

    """

    t_part = temp_fac(t, duration=duration, sigmat=sigmat)
    lon_part = lon_fac(mlon, centerlon=centerlon, width=width)
    lat_part = lat_fac(mlat, L=L, scaling=scaling)

    fac = t_part * lon_part * lat_part

    return fac


##################################
# Example use
##################################

# Set some parameters
centerlon = 105  # the longitudinal cenrte (in degrees) of SCW structure
width = 90  # longitudinal width in degrees of SCW feature
scaling = 10  # increase the resulting FAC magnitudes, since the fitted values are too small (AMPERE does not capture small scale stuff)
duration = 50  # duration of time to model, in minutes
sigmat = 5  # Sigma of the Gaussian temporal modulation of the pattern [minutes]

# Make evaluation locations
_times = np.arange(0, 200, 10)  # temporal locations to evaluare for FAC [minuted]
_mlats = np.linspace(50, 85, 800)  # mlats to evaluate [degrees]
_mlons = np.linspace(
    centerlon - width * 0.5, centerlon + width * 0.5, 100
)  # mlons to evaluate [degrees]
shape = (_times.size, _mlats.size, _mlons.size)
times, mlats, mlons = np.meshgrid(
    _times, _mlats, _mlons, indexing="ij"
)  # make 3D grid of locations
fac = fac_input(times, mlons, mlats, centerlon=centerlon, width=width, scaling=10)  # [A/m2]

# Some plotting
clim = 4e-6  # A/m2
tind = 10  # time index to show
plt.figure()
plt.pcolormesh(
    mlons[tind, :, :], mlats[tind, :, :], fac[tind, :, :], cmap="bwr", vmin=-clim, vmax=clim
)
plt.xlabel("mlon [deg]")
plt.ylabel("mlat [deg]")
plt.title("FAC at evaluation locations @ time index %i [$\mu A/m^2$]" % tind)
plt.colorbar()
