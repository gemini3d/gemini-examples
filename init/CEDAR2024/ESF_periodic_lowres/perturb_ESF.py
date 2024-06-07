from __future__ import annotations
import typing as T
import numpy as np

import gemini3d.read
import gemini3d.write


def perturb_ESF(cfg: dict[str, T.Any], xg: dict[str, T.Any]):
    """
    perturb plasma from initial_conditions file
    """

    # %% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
    print(" Applying Gaussian perturbation to bottomside F-region...")
    dat = gemini3d.read.frame(cfg["indat_file"], var=["ns", "Ts", "vs1"])
    nsperturb = dat["ns"]

    # Define a shape function for a perturbation on this grid
    alt = xg["alt"]
    mlat = 90 - np.rad2deg(xg["theta"])
    mlon = np.rad2deg(xg["phi"])
    mlonmean = mlon.mean()
    mlatmean = 0.0
    altmean = 300e3
    sigmlon = 0.25
    sigmlat = 2.5
    sigalt = 15e3
    shapefn = (
        np.exp(-((alt - altmean) ** 2) / 2 / sigalt**2)
        * np.exp(-((mlon - mlonmean) ** 2) / 2 / sigmlon**2)
        * np.exp(-((mlat - mlatmean) ** 2) / 2 / sigmlat**2)
    )
    n1 = nsperturb[0, :, :, :]
    n1perturb = n1 - shapefn * 0.25 * n1
    nsperturb[0, :, :, :] = n1perturb
    nsperturb = np.maximum(nsperturb, 1e4)
    # enforce a density floor (particularly need to pull out negative densities
    # which can occur when noise is applied)
    nsperturb[-1, :, :, :] = nsperturb[:-1, :, :, :].sum(axis=0)  # enforce quasineutrality

    dat["ns"] = nsperturb

    # %% WRITE OUT THE RESULTS TO the same file
    gemini3d.write.state(cfg["indat_file"], dat)
