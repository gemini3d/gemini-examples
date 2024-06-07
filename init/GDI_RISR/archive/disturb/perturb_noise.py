from __future__ import annotations
import typing as T
import numpy as np
import numpy.random

import gemini3d.read
import gemini3d.write


def perturb_noise(cfg: dict[str, T.Any], xg: dict[str, T.Any]):
    """
    perturb plasma from initial_conditions file
    """

    # %% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
    dat = gemini3d.read.data(cfg["indat_file"], var=["ns", "Ts", "vs1"])
    nsperturb = dat["ns"]
    lsp = nsperturb.shape[0]

    # Apply noise perturbation one profile at a time
    for i in range(lsp - 1):
        for j in range(xg["lx"][1]):
            for k in range(xg["lx"][2]):
                amplitude = numpy.random.standard_normal(xg["lx"][0])
                # AWGN - note that can result in subtractive effects on density so apply a floor later!!!
                amplitude = 0.01 * amplitude
                # amplitude standard dev. is scaled to be 1% of reference profile

                if (j > 9) and (j < xg["lx"][1] - 10):
                    # do not apply noise near the edge (avoids boundary artifacts)
                    nsperturb[i, :, j, k] = (
                        nsperturb[i, :, j, k] + amplitude * nsperturb[i, :, j, k]
                    )

    nsperturb = np.maximum(nsperturb, 1e4)
    # enforce a density floor (particularly need to pull out negative densities
    # which can occur when noise is applied)
    nsperturb[-1, :, :, :] = nsperturb[:-1, :, :, :].sum(axis=0)  # enforce quasineutrality

    # # %% KILL OFF THE E-REGION WHICH WILL DAMP THE INSTABILITY (AND USUALLY ISN'T PRESENT IN PATCHES)
    # x1ref = 200e3
    # # where to start tapering down the density in altitude
    # dx1 = 10e3
    # taper = 0.5 + 0.5 * np.tanh((x1 - x1ref) / dx1)
    # for i in range(lsp - 1):
    #     for ix3 in range(xg["lx"][2]):
    #         for ix2 in range(xg["lx"][1]):
    #             nsperturb[i, :, ix2, ix3] = 1e6 + nsperturb[i, :, ix2, ix3] * taper

    # nsperturb[-1, :, :, :] = nsperturb[:-1, :, :, :].sum(axis=0)
    # # enforce quasineutrality

    # %% WRITE OUT THE RESULTS TO the same file
    gemini3d.write.state(
        cfg["indat_file"],
        dat,
        ns=nsperturb,
        # file_format=cfg["file_format"],
    )
