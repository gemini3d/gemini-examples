%% Iowa grid for AGU 2019
%{
dtheta=19;
dphi=29;
lp=100;
lq=200;
lphi=210;
altmin=80e3;
glat=40;   %38.9609;
glon=360-94.088;
gridflag=1;
flagsource=1;
iscurv=true;
%}
p.dtheta=16;
p.dphi=26;
p.lp=100;
p.lq=200;
p.lphi=210;
p.altmin=80e3;
p.glat=41.5;   %38.9609;
p.glon=360-94.088;
p.gridflag=1;
p.flagsource=1;
p.iscurv=true;


%% GEOGRAPHIC COORDINATES OF NEUTRAL SOURCE (OR GRID CENTER)
% Iowa example
neuinfo.sourcelat=38.9609;
neuinfo.sourcelong=360-94.088;
neuinfo.neugridtype=3;    %1 = Cartesian neutral grid (2D), 2 - axisymmetric (2D), 3 - 3D Cartesian
neuinfo.zmin=0;
neuinfo.zmax=375;
neuinfo.xmin=-1200;
neuinfo.xmax=1200;
neuinfo.ymin=-1200;
neuinfo.ymax=1200;
neuinfo.rhomax=[];        %meaningless in 3D situations


%MATLAB GRID GENERATION
if ~exist('xg', 'var')
  %xg= gemini3d.grid.tilted_dipole3d(p);
  %xg= gemini3d.grid.tilteddipole_varx2_3D(p);
  xg= gemini3d.grid.makegrid_tilteddipole_varx2_oneside_3D(p);
end

%PLOT THE GRID IF DESIRED
gemini3d.plot.grid(xg,flagsource,neuinfo)

%SAVE THE GRID DATA
p.eq_dir='~/simulations/iowa3D_eq/';
p.outdir='~/simulations/iowa3D_medres';

dint = gemini3d.model.eq2dist(p, xg);
