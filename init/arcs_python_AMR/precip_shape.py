import numpy as np
import xarray


def precip_shape(pg: xarray.Dataset, Qpeak: float, Qbackground: float) -> xarray.DataArray:
    """
    makes a 2D Gaussian shape in Latitude, Longitude
    """

    # center locations in space and time
    mlon_mean = pg.mlon.mean().item()
    mlat_mean = pg.mlat.mean().item()
    displace = 10 * pg.mlat_sigma

    # Evaluation locations in space and time
    lt = pg.time.size
    timeref = pg.time[0]
    timesec = np.empty(lt)
    for it in range(0, lt):
        dt = pg.time[it].values - timeref.values
        timesec[it] = dt.astype("timedelta64[s]").item().total_seconds()
    _times = timesec  # temporal locations to evaluate
    _mlats = pg.mlat
    _mlons = pg.mlon

    t_mean = _times.mean()
    # t_sigma=1/8*(_times.min()+_times.max())
    t_sigma = 45

    # Discrete auroral precipitation
    times, mlats, mlons = np.meshgrid(
        _times, _mlats, _mlons, indexing="ij"
    )  # make 3D grid of locations
    Q = np.empty((lt, _mlons.size, _mlats.size))

    mlatctr = mlat_mean + displace * np.tanh((pg.mlon - mlon_mean) / (2 * pg.mlon_sigma))
    # changed so the arc is wider compared to its twisting
    for it in range(0, lt):
        time = _times[it]
        Q[it, :, :] = (
            Qpeak
            * np.exp(-((pg.mlon - mlon_mean) ** 2) / 2 / pg.mlon_sigma**2)
            * np.exp(-((pg.mlat - mlatctr - 1.5 * pg.mlat_sigma) ** 2) / 2 / pg.mlat_sigma**2)
            * np.exp(-((time - t_mean) ** 2) / 2 / t_sigma**2)
        )

    # from matplotlib.pyplot import figure,show
    # fg = figure()
    # ax = fg.gca()
    # hi = ax.pcolormesh(pg.mlon, pg.mlat, Q)
    # fg.colorbar(hi, ax=ax)
    # ax.set_title("arcs: precip_shape: Q")
    # ax.set_xlabel("MLON")
    # ax.set_ylabel("MLAT")
    # show()

    return Q.clip(min=Qbackground)
