from __future__ import annotations
import typing as T
import numpy as np
import numpy.random

import gemini3d.read
import gemini3d.write

# WARNING: Values used in this script are extremely unrealistic (LL - 2025-07-11)

def perturb_GDI_planar(cfg: dict[str, T.Any], xg: dict[str, T.Any]):
    """
    perturb plasma from initial_conditions file
    """

    # %% READ IN THE SIMULATION INFORMATION
    # trim ghost cells
    x1 = xg["x1"][2:-2]
    x2 = xg["x2"][2:-2]

    # %% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
    dat = gemini3d.read.frame(cfg["indat_file"], var=["ns", "Ts", "vs1"])
    ns = dat["ns"]
    lsp = ns.shape[0]

    # %% Choose a single profile from the center of the eq domain as a reference
    ix2 = xg["lx"][1] // 2
    ix3 = xg["lx"][2] // 2


    # START WITH A UNIFORM REFERENCE PROFILE
    uniform_profile = ns[:, :, ix2, ix3]
    expanded_profile = np.expand_dims(uniform_profile, axis=(2,3))
    nsscale = np.broadcast_to(expanded_profile, ns.shape)
    nsscale = np.copy(nsscale)

    # %% SCALE EQ PROFILES UP TO SENSIBLE BACKGROUND CONDITIONS
    scalefact = 10
    nsscale = scalefact * nsscale
    nsscale[-1, :, :, :] = nsscale[:-1, :, :, :].sum(axis=0)

    # %% GDI EXAMPLE (PERIODIC) INITIAL DENSITY STRUCTURE AND SEEDING
    ell = 20e3         # gradient scale length for patch/blob
    x21 = -600e3       # location on one of the patch edges
    x22 = -500e3       # other patch edge
    nepatchfact = 10   # density increase factor over background
    # Add patch to background
    expanded_x2 = np.expand_dims(x2, axis=(0,1,3))
    nsperturb = nsscale + nepatchfact * nsscale * (1 / 2 * np.tanh((expanded_x2 - x21) / ell) - 1 / 2 * np.tanh((expanded_x2 - x22) / ell))

    print('PERTURB FUNCTION')
    print(nsperturb[nsperturb<0])

    # %% WRITE OUT THE RESULTS TO the same file
    gemini3d.write.state(
        cfg["indat_file"],
        dat,
        ns=nsperturb,
    )
