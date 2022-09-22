# model_reconstruct.py
# Create an interpolation suitable for ingesting into numerical models or raytracing
# This technique emphasises eliminating artifacts over precice reconstruction of all
# features in the data, and ensure the boundaries behave in a physically sensible
# way.

import numpy as np
import h5py
from scipy.optimize import curve_fit
from scipy.spatial import Delaunay
import matplotlib.pyplot as plt
from scipy.interpolate import RBFInterpolator


def chapman_piecewise(z, A, Ht, Hb, z0):

    # From Schunk and Nagy, 2009; eqn 11.57
    # Topside
    zp = (z-z0)/Ht
    NeT = A*np.exp(1-zp-np.exp(-zp))

    # Bottomside
    zp = (z-z0)/Hb
    NeB = A*np.exp(1-zp-np.exp(-zp))

    Ne = NeB.copy()
    Ne[z>z0] = NeT[z>z0]

    return Ne


# input:
# filename, input time, grid parameters

# read in datafile

def interp_amisr(amisr_file, iso_time, coords):

    # File read in - this can be shared with other parts of the code
    # amisr_file = '/Users/e30737/Desktop/Data/AMISR/RISR-N/2017/20171119.001_lp_1min-fitcal.h5'
    # amisr_file = '/Users/e30737/Desktop/Data/AMISR/RISR-N/2019/20190510.001_lp_5min-fitcal.h5'
    # amisr_file = '/Users/e30737/Desktop/Data/AMISR/synthetic/imaging_chapman.h5'
    with h5py.File(amisr_file, 'r') as h5:
        beamcode = h5['BeamCodes'][:]
        lat = h5['Geomag/Latitude'][:]
        lon = h5['Geomag/Longitude'][:]
        alt = h5['Geomag/Altitude'][:]
        dens = h5['FittedParams/Ne'][:]
        dens_err = h5['FittedParams/dNe'][:]
        chi2 = h5['FittedParams/FitInfo/chi2'][:]
        fitcode = h5['/FittedParams/FitInfo/fitcode'][:]
        site_lat = h5['Site/Latitude'][()]
        site_lon = h5['Site/Longitude'][()]
        site_alt = h5['Site/Altitude'][()]
        utime = h5['Time/UnixTime'][:,0]
        # print(dt.datetime.utcfromtimestamp(h5['Time/UnixTime'][0,0]))

    # print(np.diff(range0))
    # time = utime.astype(np.datetime64)
    time = utime.astype('datetime64[s]')
    # print(time[0].astype('datetime64[s]'))

    # lat = lat[np.isfinite(dens)]
    # lon = lon[np.isfinite(dens)]
    # alt = alt[np.isfinite(dens)]
    # eobs = dens_err[np.isfinite(dens)]
    # vobs = dens[np.isfinite(dens)]

    # data_check = np.array([dens_err>1.e10, dens_err<1.e12, chi2>0.1, chi2<10., np.isin(fitcode,[1,2,3,4])])
    data_check = np.array([chi2>0.1, chi2<10., np.isin(fitcode,[1,2,3,4])])
    # If ANY elements of data_check are FALSE, flag index as bad data
    bad_data = np.squeeze(np.any(data_check==False,axis=0,keepdims=True))
    dens[bad_data] = np.nan
    dens_err[bad_data] = np.nan


    # Time specific - can extract and use multiple calls without reloading data
    # targtime = np.datetime64('2017-11-21T19:20')
    targtime = np.datetime64(iso_time)
    print(targtime)
    tidx = np.argmin(np.abs(time-targtime))
    # print(alt.shape, dens[tidx,:,:].shape)
    # background_alt = alt.flatten()
    # background_dens = dens[tidx,:,:].flatten()
    # print(background_alt.shape, background_dens.shape)
    # print(tidx, time[tidx].astype('datetime64[s]'))



    # Beam clustering - this will be the same throughout experiments
    # Error propigation here??
    # This adds covariance between beams
    # points = np.array([[0, 0], [0, 1.1], [1, 0], [1, 1]])
    # points = beamcode[:,1:3]
    r = np.cos(beamcode[:,2]*np.pi/180.)
    t = beamcode[:,1]*np.pi/180.
    points = np.array([r*np.sin(t), r*np.cos(t)]).T
    # print(points.shape)

    tri = Delaunay(points)

    # plt.triplot(points[:,0], points[:,1], tri.simplices)
    # plt.plot(points[:,0], points[:,1], 'o')
    # plt.show()

    # ax = fig.add_subplot(111, projection='polar')
    # ax.triplot(points[:,0], points[:,1], tri.simplices)
    # ax.plot(points[:,0], points[:,1], 'o')
    # print(tri.simplices)


    # Fit chapman to each beam
    chapman_coefficients = []
    clust_az = []
    clust_el = []
    for clust_index in tri.simplices:
        # for a, d, dd in zip(alt, dens[tidx], dens_err[tidx]):
        # print(a.shape, d.shape)
        # a = alt[clust_index]/1.e6
        a = alt[clust_index]
        d = dens[tidx,clust_index,:]
        dd = dens_err[tidx,clust_index,:]
        try:
            # K = phi(a[np.isfinite(d)], c)
            # print(a)
            # coeffs, _, _, _ = np.linalg.lstsq(K.T,d[np.isfinite(d)], rcond=None)
            # print(coeffs)

            # coeffs, _ = curve_fit(chapman, a[np.isfinite(d)], d[np.isfinite(d)], p0=[2.e11,0.5,150.*1000., 300.*1000.], bounds=[[0.,0.,0.,0.],[np.inf,np.inf,np.inf,np.inf]], absolute_sigma=True)
            # coeffs, _ = curve_fit(chapman_piecewise, a[np.isfinite(d)], d[np.isfinite(d)], sigma=dd[np.isfinite(d)], p0=[2.e11,50.*1000.,50.*1000., 300.*1000.], bounds=[[0.,0.,0.,0.],[np.inf,np.inf,np.inf,np.inf]], absolute_sigma=True)
            coeffs, _ = curve_fit(chapman_piecewise, a[np.isfinite(d) & ~((a>400.*1000) & (dd<5.e10) & (d<5.e10))], d[np.isfinite(d) & ~((a>400.*1000) & (dd<5.e10) & (d<5.e10))], sigma=dd[np.isfinite(d) & ~((a>400.*1000) & (dd<5.e10) & (d<5.e10))], p0=[4.e11,100.*1000.,50.*1000., 300.*1000.], bounds=[[0.,0.,0.,0.],[np.inf,5.e6,np.inf,np.inf]], absolute_sigma=True)
            # print(coeffs)
        except RuntimeError:
            coeffs = [np.nan, np.nan, np.nan, np.nan]
            # continue
        # print(coeffs)
        # print(popt)
        chapman_coefficients.append(coeffs)
        clust_az.append(np.mean(beamcode[clust_index,1]))
        clust_el.append(np.mean(beamcode[clust_index,2]))

    #     fig = plt.figure()
    #     ax = fig.add_subplot(111)
    #
    #     ax.scatter(a[(a>400.*1000) & (dd<5.e10) & (d<5.e10)], d[(a>400.*1000) & (dd<5.e10) & (d<5.e10)], color='hotpink', s=150)
    #
    #     c = ax.scatter(a, d, c=dd, vmin=0., vmax=3.e11)
    #     plt.colorbar(c, label=r'Electron Density Error (m$^{-3}$)')
    #
    #     # # Also remove high altitude points with extremely low error and low Ne values - these bias the topside fit
    # # bad_data = ((alt>400.*1000) & (dens_err<1.e10) & (dens<5.e10))
    # # dens[bad_data] = np.nan
    # # dens_err[bad_data] = np.nan
    #
    #     ai = np.arange(100., 700., 1.)*1000.
    #     # ai = np.arange(100., 700., 1.)*1000./1.e6
    #     # di = chapman(np.arange(100., 700., 1.)*1000., *coeffs)
    #     di = chapman_piecewise(np.arange(100., 700., 1.)*1000., *coeffs)
    #     # di = chapman_piecewise(np.arange(100., 700., 1.)*1000., coeffs[0], 50.*1000., 100.*1000., coeffs[3])
    #     # K = phi(ai, c)
    #     # di = np.dot(K.T, coeffs)
    #     ax.plot(ai, di, color='orange')
    #     ax.set_ylim([0.,1.e12])
    #     ax.set_xlabel('Altitude (m)')
    #     ax.set_ylabel(r'Electron Density (m$^{-3}$)')
    #     ax.text(100000., 9.5e11, 'NmF2={:.2e}'.format(coeffs[0]))
    #     ax.text(100000., 9.0e11, 'HmT={:.2e}'.format(coeffs[1]))
    #     ax.text(100000., 8.5e11, 'HmB={:.2e}'.format(coeffs[2]))
    #     ax.text(100000., 8.0e11, 'hmF2={:.2e}'.format(coeffs[3]))

    chapman_coefficients = np.array(chapman_coefficients)
    clust_az = np.array(clust_az)
    clust_el = np.array(clust_el)
    # print(chapman_coefficients.shape, clust_az.shape, clust_el.shape)


    # # Comment out
    # # Polar plots to validate
    # r = np.cos(clust_el*np.pi/180.)
    # t = clust_az*np.pi/180.
    #
    # fig = plt.figure(figsize=(12,12))
    # ax = fig.add_subplot(221, projection='polar')
    # ax.set_theta_zero_location('N')
    # ax.set_theta_direction(-1)
    # c = ax.scatter(t, r, c=chapman_coefficients[:,0], s=100., vmin=0, vmax=5.e11)
    # plt.colorbar(c, label=r'NmF2 (m$^{-3}$)')
    # ax.set_title('NmF2')
    #
    # ax = fig.add_subplot(222, projection='polar')
    # ax.set_theta_zero_location('N')
    # ax.set_theta_direction(-1)
    # c = ax.scatter(t, r, c=chapman_coefficients[:,1], s=100., vmin=50, vmax=150.*1000.)
    # plt.colorbar(c, label=r'HmT (m)')
    # ax.set_title('Topside Scale Height')
    #
    # ax = fig.add_subplot(223, projection='polar')
    # ax.set_theta_zero_location('N')
    # ax.set_theta_direction(-1)
    # c = ax.scatter(t, r, c=chapman_coefficients[:,2], s=100., vmin=50, vmax=150.*1000.)
    # plt.colorbar(c, label=r'HmB (m)')
    # ax.set_title('Bottomside Scale Height')
    #
    # ax = fig.add_subplot(224, projection='polar')
    # ax.set_theta_zero_location('N')
    # ax.set_theta_direction(-1)
    # c = ax.scatter(t, r, c=chapman_coefficients[:,3], s=100., vmin=200.*1000., vmax=400.*1000.)
    # plt.colorbar(c, label=r'hmF2 (m)')
    # ax.set_title('hmF2')
    # plt.show()

    # for i in range(len(r)):
    #     ax.annotate(str(i), (t[i], r[i]))

    avg_coeffs = np.nanmean(chapman_coefficients, axis=0)
    # print(avg_coeffs)

    # ai = np.arange(100., 700., 1.)*1000.
    # di = chapman_piecewise(np.arange(100., 700., 1.)*1000., *avg_coeffs)
    # plt.plot(ai, di, color='orange')
    # plt.xlabel('Altitude (m)')
    # plt.ylabel(r'Electron Density (m$^{-3}$)')
    # plt.show()


    # 2D RBF interpolation
    # This transformation is wrong - effectively turns all beams vertical at 300 km
    d = chapman_coefficients[:,0].copy()


    r = np.cos(clust_el*np.pi/180.)
    t = clust_az*np.pi/180.
    x = 300.*1000./np.sin(clust_el*np.pi/180.)*r*np.sin(t)
    y = 300.*1000./np.sin(clust_el*np.pi/180.)*r*np.cos(t)


    # Add edge points
    # Do this more rigerously with boundary conditions?
    xc = np.mean(x)
    yc = np.mean(y)
    r = 400.0*1000.
    th = np.linspace(0.,2*np.pi, 50, endpoint=False)
    xe = xc + r*np.cos(th)
    ye = yc + r*np.sin(th)
    de = np.full(xe.shape, 2.e11)

    xp = np.concatenate((x,xe))
    yp = np.concatenate((y,ye))
    dp = np.concatenate((d,de))


    # xgrid, ygrid = np.meshgrid(np.linspace(-1500.,1500.,50), np.linspace(-1500.,1500.,50))
    newx, newy, newz = coords

    newxgrid, newygrid, newzgrid = np.meshgrid(newx, newy, newz)

    # # interpolate to new grid
    # interp_NmF2 = interpn((xgrid0[0,:], ygrid0[:,0]), NmF2, (newxgrid.flatten(), newygrid.flatten()), method='linear', bounds_error=False, fill_value=2.e11)
    # interp_NmF2 = interp_NmF2.reshape(newxgrid.shape)


    # Replace with custom RBF interpolator?
    # This might allow more efficiency/customization
    # print(np.array([x,y]).shape, chapman_coefficients[:,0].shape)
    interp = RBFInterpolator(np.array([xp,yp]).T, dp)
    dflat = interp(np.array([newxgrid.flatten(), newygrid.flatten()]).T)
    dgrid = dflat.reshape(newxgrid.shape)
    # print(newzgrid.shape, dgrid.shape)

    interp_dens = chapman_piecewise(newzgrid, dgrid, avg_coeffs[1], avg_coeffs[2], avg_coeffs[3])
    # print(interp_dens.shape)

    # # fig, ax = plt.subplots()
    # fig = plt.figure(figsize=(15,7))
    # ax = fig.add_subplot(121)
    # ax.pcolormesh(xgrid, ygrid, dgrid, vmin=0., vmax=5.e11, shading='gouraud')
    # p = ax.scatter(xp, yp, c=dp, s=50, ec='k', vmin=0., vmax=5.e11)
    # ax.set_xlabel('X (km)')
    # ax.set_ylabel('Y (km)')
    # fig.colorbar(p, label=r'Electron Density (m$^{-3}$)')
    #
    # ax = fig.add_subplot(122)
    # ax.pcolormesh(xgrid, ygrid, dgrid, vmin=0., vmax=5.e11, shading='gouraud')
    # p = ax.scatter(xp, yp, c=dp, s=50, ec='k', vmin=0., vmax=5.e11)
    # ax.set_xlim([-100.,400.])
    # ax.set_ylim([0.,500.])
    # ax.set_xlabel('X (km)')
    # ax.set_ylabel('Y (km)')
    # fig.colorbar(p, label=r'Electron Density (m$^{-3}$)')
    # plt.show()


    # # Validate with plots
    # import matplotlib.pyplot as plt
    # for ia in range(len(newz)):
    #     c = plt.pcolormesh(newxgrid[:,:,ia], newygrid[:,:,ia], interp_dens[:,:,ia], vmin=0., vmax=5.e11)
    #     plt.colorbar(c)
    #     plt.show()
    #
    return interp_dens


def main():
    amisr_file = '/Users/e30737/Desktop/Data/AMISR/RISR-N/2016/20161127.002_lp_1min-fitcal.h5'
    iso_time = '2016-11-27T22:55'
    coords = [np.linspace(-300.,500.,50)*1000., np.linspace(-200.,600.,50)*1000., np.linspace(100., 500., 30)*1000.]
    interp_dens = interp_amisr(amisr_file, iso_time, coords)
    # xgrid, ygrid = np.meshgrid()




if __name__ == '__main__':
    main()