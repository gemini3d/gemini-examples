%% RISR PERIODIC KHI RUN
pgrid.xdist=239.0625e3;
pgrid.ydist=159.375e3;
pgrid.lxp=256;
pgrid.lyp=256;
pgrid.glat=75.6975;
pgrid.glon=360.0-94.8322;
pgrid.gridflag=0;
pgrid.Bincl=90;
pgrid.alt_min=80e3;
pgrid.alt_max=975e3;
pgrid.alt_scale=[50e3, 45e3, 400e3, 150e3];    %super coarse along the field line...



%% RUN THE GRID GENERATION CODE
if (~exist('xg','var'))
  xg=makegrid_cart_3D(pgrid);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% Interpolate data to desired grid resolution
pfile.file_format = 'raw';
pfile.eq_dir='../../../simulations/RISR_eq/';
pfile.simdir='~/simulations/input/KHI_periodic_lowres/';
[nsi,vs1i,Tsi]=eq2dist(pfile,xg);
