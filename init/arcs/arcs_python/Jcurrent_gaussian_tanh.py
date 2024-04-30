import numpy as np
import xarray


def Jcurrent_gaussian_tanh(E: xarray.Dataset, gridflag: int, flagdip: bool) -> xarray.Dataset:
    """
    Set the top boundary shape (current density) and potential solve type
    flag.  Can be adjusted by user to achieve any desired shape.
    """

    Jpk = E.Jtarg
    llon = E.mlon.size
    llat = E.mlat.size

    displace = 10 * E.mlatsig
    mlatctr = E.mlatmean + displace * np.tanh((E.mlon - E.mlonmean) / (2 * E.mlonsig))
    # changed so the arc is wider compared to its twisting
    for i, t in enumerate(E.time):
        E["flagdirich"].loc[t] = 0
        E["Vminx1it"].loc[t] = np.zeros((llon, llat))
        if i > 2:
            E["Vmaxx1it"].loc[t] = (
                Jpk
                * np.exp(-((E.mlon - E.mlonmean) ** 2) / 2 / E.mlonsig**2)
                * np.exp(-((E.mlat - mlatctr - 1.5 * E.mlatsig) ** 2) / 2 / E.mlatsig**2)
            )
            E["Vmaxx1it"].loc[t] = E["Vmaxx1it"].loc[t] - Jpk * np.exp(
                -((E.mlon - E.mlonmean) ** 2) / 2 / E.mlonsig**2
            ) * np.exp(-((E.mlat - mlatctr + 1.5 * E.mlatsig) ** 2) / 2 / E.mlatsig**2)
        else:
            E["Vmaxx1it"].loc[t] = np.zeros((llon, llat))

    return E
