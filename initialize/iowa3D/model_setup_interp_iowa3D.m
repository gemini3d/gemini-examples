cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils'])
addpath([gemini_root, filesep, 'setup/gridgen'])
addpath([gemini_root, filesep, '../GEMINI-scripts/setup/gridgen'])
addpath([gemini_root, filesep, 'setup/'])
addpath([gemini_root, filesep, 'vis'])
addpath(['../../setup/gridgen'])


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
gridflag=0;
flagsource=1;
iscurv=true;
%}
dtheta=16;
dphi=29;
lp=100;
lq=200;
lphi=210;
altmin=80e3;
glat=41.5;   %38.9609;
glon=360-94.088;
gridflag=1;
flagsource=1;
iscurv=true;


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
if (~exist('xg'))
  %xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
  %xg=makegrid_tilteddipole_varx2_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
  xg=makegrid_tilteddipole_varx2_oneside_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);  
end


%PLOT THE GRID IF DESIRED
ha=plotgrid(xg,flagsource,neuinfo);


%SAVE THE GRID DATA
eqdir='../../../simulations/iowa3D_eq/';
simID='iowa3D_medres';
[nsi,vs1i,Tsi,xgin,ns,vs1,Ts]=eq2dist(eqdir,simID,xg);

