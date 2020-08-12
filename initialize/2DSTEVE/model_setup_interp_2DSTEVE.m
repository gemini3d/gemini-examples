%% 2D EXAMPLE FOR STEVE TESTING
pgrid.xdist=200e3;    %eastward distance
pgrid.ydist=600e3;    %northward distance
pgrid.lxp=128;
pgrid.lyp=1;
pgrid.glat=67.11;
pgrid.glon=212.95;
pgrid.gridflag=0;
pgrid.Bincl=90;
pgrid.alt_min=80e3;
pgrid.alt_max=975e3;
pgrid.alt_scale=[10e3, 8e3, 500e3, 150e3];    %parameters setting the nonuniform structure of the grid


%% RUN THE GRID GENERATION CODE
if ~exist('xg', 'var')
  xg=makegrid_cart_3D(pgrid);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% ALTERNATIVELY WE MAY WANT TO READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
pfile.file_format = 'raw';
pfile.eq_dir='../../../simulations/2Dtest_eq/';
pfile.simdir='~/simulations/input/2DSTEVE';
[nsi,vs1i,Tsi]=eq2dist(pfile,xg);
