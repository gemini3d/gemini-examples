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
    print(" !Applying Gaussian perturbation to bottomside F-region...")
    dat = gemini3d.read.frame(cfg["indat_file"], var=["ns", "Ts", "vs1"])
    nsperturb = dat["ns"]
    
    # The fastest growing perturbations will be those that have strong
    #   field-aligned coherence
    x1=xg["x1"][2:-2]
    x2=xg["x2"][2:-2]
    x3=xg["x3"][2:-2]
    meanx3=x3.mean()
    altmean=300e3         # approximate location of perturbation
    ix1=xg["lx"][0]//2    # magnetic equator
    ix3=xg["lx"][2]//2
    ix2=np.argmin(abs(xg["alt"][ix1,:,ix3]-altmean))
    meanx2=x2[ix2]        # x2 position where we center the perturbation
    x2dist=x2.max()-x2.min()
    x3dist=x3.max()-x3.min()
    sigx2=0.1*x2dist
    sigx3=0.05*x3dist
    [X1,X2,X3]=np.meshgrid(x1,x2,x3,indexing="ij")
    shapefn = (
        np.exp(-((X2 - meanx2) ** 8) / 2 / sigx2**8)
        * np.exp(-((X3 - meanx3) ** 2) / 2 / sigx3**2)
    )
    
    # alt = xg["alt"]
    # mlat = 90 - np.rad2deg(xg["theta"])
    # mlon = np.rad2deg(xg["phi"])
    # mlonmean = mlon.mean()
    # mlatmean = 0.0
    # altmean = 350e3
    # sigmlon = 0.25
    # sigmlat = 2.5
    # sigalt = 15e3
    # shapefn = (
    #     np.exp(-((alt - altmean) ** 2) / 2 / sigalt**2)
    #     * np.exp(-((mlon - mlonmean) ** 2) / 2 / sigmlon**2)
    #     * np.exp(-((mlat - mlatmean) ** 2) / 2 / sigmlat**2)
    # )
       
    n1 = nsperturb[0, :, :, :]
    n1perturb = n1 - shapefn * 0.85 * n1
    nsperturb[0, :, :, :] = n1perturb
    nsperturb = np.maximum(nsperturb, 1e4)
    # enforce a density floor (particularly need to pull out negative densities
    # which can occur when noise is applied)
    nsperturb[-1, :, :, :] = nsperturb[:-1, :, :, :].sum(axis=0)  # enforce quasineutrality

    dat["ns"] = nsperturb

    # %% WRITE OUT THE RESULTS TO the same file
    gemini3d.write.state(cfg["indat_file"], dat)
