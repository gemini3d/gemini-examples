addpath ../../../GEMINI-scripts/setup/gridgen;


%% Setup a coarse grid for testing GDI development
pgrid.xdist=200e3;    %eastward distance
pgrid.ydist=50e3;    %northward distance (periodic here)
pgrid.lxp=512;
pgrid.lyp=128;
pgrid.glat=75.6975;
pgrid.glon=360.0-94.8322;
pgrid.gridflag=0;
pgrid.Bincl=90;
pgrid.alt_min=80e3;
pgrid.alt_max=975e3;
pgrid.alt_scale=[30e3, 25e3, 500e3, 150e3];    %parameters setting the nonuniform structure of the grid


%% RUN THE GRID GENERATION CODE
if (~exist('xg','var'))
  xg=makegrid_cart_3D(pgrid);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% Interpolate data to desired grid resolution
pfile.file_format = 'raw';
pfile.eqdir='../../../simulations/RISR_eq/';
pfile.realbits=64;
pfile.simdir='~/simulations/input/GDI_periodic_lowres/';
[nsi,vs1i,Tsi]=eq2dist(pfile,xg);
