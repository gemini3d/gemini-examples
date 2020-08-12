%cwd = fileparts(mfilename('fullpath'));
run('../../setup.m')
addpath('../../../GEMINI-scripts/matlab/setup/gridgen')
p.file_format = 'h5';

%MOORE, OK GRID (FULL)
dtheta=20;
dphi=27.5;
%lp=350;
%lq=550;
%lphi=288;
lp=256;
lq=256;
lphi=210;
altmin=80e3;
glat=39;
glon=262.51;
%gridflag=0;
gridflag=1;


%MATLAB GRID GENERATION
if (~exist('xg'))
  %xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
  %xg=makegrid_tilteddipole_varx2_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
  xg=makegrid_tilteddipole_varx2_oneside_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end


%PLOT THE GRID IF DESIRED
flagsource=0;
sourcelat=glat;
sourcelong=glon;
neugridtype=[];
zmin=[];
zmax=[];
rhomax=[];
%ha=plotgrid(xg,flagsource,sourcelat,sourcelong,neugridtype,zmin,zmax,rhomax);


%SAVE THE GRID DATA
p.eq_dir='../../../simulations/mooreOK3D_hemis_eq/';
p.indat_size = '../../../simulations/mooreOK3D_hemis_inputs/simsize.h5';
p.indat_grid = '../../../simulations/mooreOK3D_hemis_inputs/simgrid.h5';
p.indat_file = '../../../simulations/mooreOK3D_hemis_inputs/initial_conditions.h5';
eq2dist(p,xg);
