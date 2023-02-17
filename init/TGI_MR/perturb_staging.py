import typing as T
import numpy as np
import numpy.random

import gemini3d.read
import gemini3d.write


def perturb_staging(cfg: T.Dict[str, T.Any], xg: T.Dict[str, T.Any]):
    """
    perturb plasma from initial_conditions file
    """

    # %% READ IN THE SIMULATION INFORMATION
    # trim ghost cells
    x1 = xg["x1"][2:-2]
    x2 = xg["x2"][2:-2]

    # %% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
    dat = gemini3d.read.data(cfg["indat_file"], var=["ns", "Ts", "vs1"])
    ns = dat["ns"]
    lsp = ns.shape[0]

    # %% Choose a single profile from the center of the eq domain as a reference
    ix2 = xg["lx"][1] // 2
    ix3 = xg["lx"][2] // 2

    nsscale = np.zeros_like(ns)
    for i in range(lsp):
        nprof = ns[i, :, ix2, ix3]
        for j in range(xg["lx"][1]):
            for k in range(xg["lx"][2]):
                nsscale[i, :, j, k] = nprof

    # %% SCALE EQ PROFILES UP TO SENSIBLE BACKGROUND CONDITIONS
    #scalefact = 10 * 6 / 8
    #scalefact = 14
    scalefact = 30   
    for i in range(lsp - 1):
        nsscale[i, :, :, :] = scalefact * nsscale[i, :, :, :]
    nsscale[-1, :, :, :] = nsscale[:-1, :, :, :].sum(axis=0)
    # enforce quasineutrality

    # %% GDI EXAMPLE (PERIODIC) INITIAL DENSITY STRUCTURE AND SEEDING
    ell = 0.5e3  # gradient scale length for patch/blob
    nepatchfact = 1/2  # density increase factor over background

    nsperturb = np.zeros_like(ns)
    for i in range(lsp - 1):
        for j in range(xg["lx"][1]):
            amplitude = numpy.random.standard_normal([xg["lx"][0], xg["lx"][2]])
            # AWGN - note that can result in subtractive effects on density so apply a floor later!!!
            amplitude = 0.00 * amplitude  # no noise!
            # amplitude standard dev. is scaled to be 1% of reference profile

            # original data
            nsperturb[i, :, j, :] = nsscale[i, :, j, :] + nepatchfact * nsscale[i, :, j, :] * (
                1 / 2 - 1 / 2 * np.tanh(x2[j] / ell)
            )
            # patch, note offset in the x2 index!!!!

            if (j > 9) and (j < xg["lx"][1] - 10):
                # do not apply noise near the edge (corrupts boundary conditions)
                nsperturb[i, :, j, :] = nsperturb[i, :, j, :] + amplitude * nsscale[i, :, j, :]

    nsperturb = np.maximum(nsperturb, 1e4)
    # enforce a density floor (particularly need to pull out negative densities
    # which can occur when noise is applied)
    nsperturb[-1, :, :, :] = nsperturb[:-1, :, :, :].sum(axis=0)  # enforce quasineutrality

    # %% KILL OFF THE E-REGION WHICH WILL DAMP THE INSTABILITY (AND USUALLY ISN'T PRESENT IN PATCHES)
    x1ref = 200e3
    # where to start tapering down the density in altitude
    dx1 = 10e3
    taper = 0.5 + 0.5 * np.tanh((x1 - x1ref) / dx1)
    for i in range(lsp - 1):
        for ix3 in range(xg["lx"][2]):
            for ix2 in range(xg["lx"][1]):
                nsperturb[i, :, ix2, ix3] = 1e6 + nsperturb[i, :, ix2, ix3] * taper

    nsperturb[-1, :, :, :] = nsperturb[:-1, :, :, :].sum(axis=0)
    # enforce quasineutrality

    # %% WRITE OUT THE RESULTS TO the same file
    gemini3d.write.state(
        cfg["indat_file"],
        dat,
        ns=nsperturb,
        file_format=cfg["file_format"],
    )
