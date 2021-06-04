import xarray
import numpy as np


def fac_said(E: xarray.Dataset, gridflag: int, flagdip: bool) -> xarray.Dataset:
    """
    for 3D sim, FAC up/down 0.5 degree FWHM
    """

    if E.mlon.size == 1 or E.mlat.size == 1:
        raise ValueError("for 3D sims only")

    # uniform in longitude
    shapelon = 1

    shapelat = np.exp(
        -((E.mlat - E.mlatmean - 1.5 * E.mlatsig) ** 2) / 2 / E.mlatsig ** 2
    ) - np.exp(-((E.mlat - E.mlatmean + 1.5 * E.mlatsig) ** 2) / 2 / E.mlatsig ** 2)

    for t in E.time[6:]:
        E["flagdirich"].loc[t] = 0

        k = "Vminx1it" if gridflag == 1 else "Vmaxx1it"
        E[k].loc[t] = E.Jtarg * shapelon * shapelat

    return E
