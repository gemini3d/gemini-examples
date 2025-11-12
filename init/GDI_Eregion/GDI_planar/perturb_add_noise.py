from __future__ import annotations
import typing as T
import numpy as np
import numpy.random

import gemini3d.read
import gemini3d.write

# WARNING: Values in this code are extremely unrealistic (LL - 2025-07-11)

def perturb_add_noise(cfg: dict[str, T.Any], xg: dict[str, T.Any]):
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

    # Add noise
    percent_noise = 0.01
    nsperturb = np.copy(ns)
    amplitude = percent_noise * np.random.standard_normal(nsperturb.shape)
    # do not apply noise near the edge (corrupts boundary conditions)
    nsperturb[:,:,5:-5,:] = nsperturb[:,:,5:-5,:] + amplitude[:,:,5:-5,:] * nsperturb[:,:,5:-5,:]

    # enforce a density floor (particularly need to pull out negative densities
    # which can occur when noise is applied)
    nsperturb = np.maximum(nsperturb, 1e4)
    nsperturb[-1, :, :, :] = nsperturb[:-1, :, :, :].sum(axis=0)  # enforce quasineutrality

    # %% WRITE OUT THE RESULTS TO the same file
    gemini3d.write.state(
        cfg["indat_file"],
        dat,
        ns=nsperturb,
    )
