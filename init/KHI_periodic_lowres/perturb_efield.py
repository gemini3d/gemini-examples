import typing as T
import xarray
import numpy as np
from scipy.interpolate import interp1d

import gemini3d.read
from gemini3d.config import datetime_range


def perturb_efield(
    cfg: T.Dict[str, T.Any], xg: T.Dict[str, T.Any], params: T.Dict[str, float] = None
):
    """Electric field boundary conditions and initial condition for KHI case arguments"""

    if not params:
        params = {
            "v0": -500,
            # background flow value, actually this will be turned into a shear in the Efield input file
            "densfact": 3,
            # factor by which the density increases over the shear region - see Keskinen, et al (1988)
            "ell": 3.1513e3,  # scale length for shear transition
            "B1val": -50000e-9,
            "x1ref": 220e3,  # where to start tapering down the density in altitude
            "dx1": 10e3,
        }

    params["vn"] = -params["v0"] * (params["densfact"] + 1) / (params["densfact"] - 1)

    # %% Sizes
    x1 = xg["x1"][2:-2]
    x2 = xg["x2"][2:-2]
    lx2 = xg["lx"][1]
    lx3 = xg["lx"][2]

    # %% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
    dat = gemini3d.read.data(cfg["indat_file"], var=["ns", "Ts", "v1"])

    nsscale = init_profile(xg, dat)

    nsperturb = perturb_density(xg, dat, nsscale, x1, x2, params)

    # %% compute initial potential, background
    Phitop = potential_bg(x2, lx2, lx3, params)

    # %% Electromagnetic parameter inputs
    create_Efield(cfg, xg, dat, nsperturb, Phitop, params)


def init_profile(xg: T.Dict[str, T.Any], dat: xarray.Dataset) -> np.ndarray:

    lsp = dat["ns"].shape[0]

    # %% Choose a single profile from the center of the eq domain
    ix2 = xg["lx"][1] // 2
    ix3 = xg["lx"][2] // 2

    nsscale = np.zeros_like(dat["ns"])
    for i in range(lsp):
        nprof = dat["ns"][i, :, ix2, ix3].values
        nsscale[i, :, :, :] = nprof[:, None, None]

    # %% SCALE EQ PROFILES UP TO SENSIBLE BACKGROUND CONDITIONS
    scalefact = 2 * 2.75
    for i in range(lsp - 1):
        nsscale[i, ...] = scalefact * nsscale[i, ...]

    nsscale[-1, ...] = nsscale[:-1, ...].sum(axis=0)
    # enforce quasineutrality

    return nsscale


def perturb_density(
    xg: T.Dict[str, T.Any],
    dat: xarray.Dataset,
    nsscale: np.ndarray,
    x1: np.ndarray,
    x2: np.ndarray,
    params: T.Dict[str, float],
) -> np.ndarray:
    """
    because this is derived from current density it is invariant with respect
    to frame of reference.
    """
    lsp = dat["ns"].shape[0]

    nsperturb = np.zeros_like(dat["ns"])
    n1 = np.zeros_like(dat["ns"])
    for i in range(lsp):
        for ix2 in range(xg["lx"][1]):
            # 3D noise
            # amplitude = np.random.randn(xg["lx"][0], 1, xg["lx"][2])
            # AGWN
            # amplitude = 0.01*amplitude

            # 2D noise
            amplitude = np.random.randn(xg["lx"][2])
            amplitude = moving_average(amplitude, 10)
            amplitude = 0.01 * amplitude

            n1here = amplitude * nsscale[i, :, ix2, :]
            # perturbation seeding instability
            n1[i, :, ix2, :] = n1here
            # save the perturbation for computing potential perturbation

            nsperturb[i, :, ix2, :] = (
                nsscale[i, :, ix2, :]
                * (params["vn"] - params["v0"])
                / (params["v0"] * np.tanh((x2[ix2]) / params["ell"]) + params["vn"])
            )
            # background density
            nsperturb[i, :, ix2, :] = nsperturb[i, :, ix2, :] + n1here
            # perturbation

    nsperturb[nsperturb < 1e4] = 1e4
    # enforce a density floor
    # particularly need to pull out negative densities which can occur when noise is applied
    nsperturb[-1, :, :, :] = nsperturb[:6, :, :, :].sum(axis=0)
    # enforce quasineutrality
    n1[-1, :, :, :] = n1[:6, :, :, :].sum(axis=0)

    # %% Remove any residual E-region from the simulation

    taper = 1 / 2 + 1 / 2 * np.tanh((x1 - params["x1ref"]) / params["dx1"])
    for i in range(lsp - 1):
        for ix3 in range(xg["lx"][2]):
            for ix2 in range(xg["lx"][1]):
                nsperturb[i, :, ix2, ix3] = 1e6 + nsperturb[i, :, ix2, ix3] * taper

    inds = x1 < 150e3
    nsperturb[:, inds, :, :] = 1e3
    nsperturb[-1, :, :, :] = nsperturb[:6, :, :, :].sum(axis=0)
    # enforce quasineutrality

    return nsperturb


def potential_bg(x2: np.ndarray, lx2: int, lx3: int, params: T.Dict[str, float]) -> np.ndarray:

    vel3 = np.empty((lx2, lx3))
    for i in range(lx3):
        vel3[:, i] = params["v0"] * np.tanh(x2 / params["ell"]) - params["vn"]

    vel3 = np.flipud(vel3)
    # this is needed for consistentcy with equilibrium...  Not completely clear why
    E2top = vel3 * params["B1val"]
    # this is -1* the electric field

    # integrate field to get potential
    DX2 = np.diff(x2)
    DX2 = np.append(DX2, DX2[-1])

    Phitop = np.cumsum(E2top * DX2[:, None], axis=0)

    return Phitop


def create_Efield(cfg, xg, dat, nsperturb, Phitop, params):

    cfg["E0dir"].mkdir(parents=True, exist_ok=True)

    # %% CREATE ELECTRIC FIELD DATASET
    E = {"llon": 100, "llat": 100}
    # NOTE: cartesian-specific code
    if xg["lx"][1] == 1:
        E["llon"] = 1
    elif xg["lx"][2] == 1:
        E["llat"] = 1

    thetamin = xg["theta"].min()
    thetamax = xg["theta"].max()
    mlatmin = 90 - np.degrees(thetamax)
    mlatmax = 90 - np.degrees(thetamin)
    mlonmin = np.degrees(xg["phi"].min())
    mlonmax = np.degrees(xg["phi"].max())

    # add a 1% buff
    latbuf = 1 / 100 * (mlatmax - mlatmin)
    lonbuf = 1 / 100 * (mlonmax - mlonmin)
    E["mlat"] = np.linspace(mlatmin - latbuf, mlatmax + latbuf, E["llat"])
    E["mlon"] = np.linspace(mlonmin - lonbuf, mlonmax + lonbuf, E["llon"])
    E["MLON"], E["MLAT"] = np.meshgrid(E["mlon"], E["mlat"], indexing="ij")

    # %% INTERPOLATE X2 COORDINATE ONTO PROPOSED MLON GRID
    xgmlon = np.degrees(xg["phi"][0, :, 0])
    # xgmlat = 90 - np.degrees(xg["theta"][0, 0, :])

    f = interp1d(xgmlon, xg["x2"][2 : xg["lx"][1] + 2], kind="linear", fill_value="extrapolate")
    x2i = f(E["mlon"])
    # f = interp1d(xgmlat, xg["x3"][2:lx3 + 2], kind='linear', fill_value="extrapolate")
    # x3i = f(E["mlat"])

    # %% SET UP TIME VARIABLES
    E["time"] = datetime_range(cfg["time"][0], cfg["time"][0] + cfg["tdur"], cfg["dtE0"])
    Nt = len(E["time"])
    # %% CREATE DATA FOR BACKGROUND ELECTRIC FIELDS
    if "Exit" in cfg:
        E["Exit"] = cfg["Exit"] * np.ones((Nt, E["llon"], E["llat"]))
    else:
        E["Exit"] = np.zeros((Nt, E["llon"], E["llat"]))

    if "Eyit" in cfg:
        E["Eyit"] = cfg["Eyit"] * np.ones((Nt, E["llon"], E["llat"]))
    else:
        E["Eyit"] = np.zeros((Nt, E["llon"], E["llat"]))

    # %% CREATE DATA FOR BOUNDARY CONDITIONS FOR POTENTIAL SOLUTION
    E["flagdirich"] = np.zeros(Nt)
    # in principle can have different boundary types for different time steps...
    E["Vminx1it"] = np.zeros((Nt, E["llon"], E["llat"]))
    E["Vmaxx1it"] = np.zeros((Nt, E["llon"], E["llat"]))
    # these are just slices
    E["Vminx2ist"] = np.zeros((Nt, E["llat"]))
    E["Vmaxx2ist"] = np.zeros((Nt, E["llat"]))
    E["Vminx3ist"] = np.zeros((Nt, E["llon"]))
    E["Vmaxx3ist"] = np.zeros((Nt, E["llon"]))

    for i in range(Nt):
        # ZEROS TOP CURRENT AND X3 BOUNDARIES DON'T MATTER SINCE PERIODIC

        # COMPUTE KHI DRIFT FROM APPLIED POTENTIAL
        vel3 = np.empty((E["llon"], E["llat"]))
        for i in range(E["llat"]):
            vel3[:, i] = params["v0"] * np.tanh(x2i / params["ell"]) - params["vn"]

        vel3 = np.flipud(vel3)

        # CONVERT TO ELECTRIC FIELD (actually -1* electric field...)
        E2slab = vel3 * params["B1val"]

        # INTEGRATE TO PRODUCE A POTENTIAL OVER GRID - then save the edge boundary conditions
        DX2 = np.diff(x2i)
        DX2 = np.append(DX2, DX2[-1])
        Phislab = np.cumsum(E2slab * DX2, axis=0)
        # use a forward difference

        E["Vmaxx2ist"][i, :] = Phislab[-1, :]
        E["Vminx2ist"][i, :] = Phislab[0, :]

    # %% Write initial plasma state out to a file
    gemini3d.write.state(
        cfg["indat_file"],
        time=cfg["time"][0],
        ns=nsperturb,
        vs=dat["vs1"],
        Ts=dat["Ts"],
        file_format=cfg["file_format"],
        Phitop=Phitop,
    )

    # %% Write electric field data to file
    gemini3d.write.Efield(E, cfg["E0dir"], cfg["file_format"])


def moving_average(x: np.ndarray, k: int):
    # https://stackoverflow.com/a/54628145
    return np.convolve(x, np.ones(k), mode="same") / k
