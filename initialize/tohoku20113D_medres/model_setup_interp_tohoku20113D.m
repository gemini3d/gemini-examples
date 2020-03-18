% cwd = fileparts(mfilename('fullpath'));
% gemini_root = [cwd, filesep, '../../../GEMINI'];
% addpath([gemini_root, filesep, 'script_utils'])
% addpath([gemini_root, filesep, 'setup/gridgen'])
% addpath([gemini_root, filesep, 'vis'])
%User must run gemini-matlab repo script setup.m to set paths


%% Parameters for EQ and new simulation
p.format='raw';
p.eqdir='~/simulations/tohoku20113D_eq/';
p.realbits=64;
p.simdir='~/simulations/input/tohoku20113D_medres';


%% A LOW/MEDIUM RES TOHOKU
dtheta=7.5;
dphi=12;
lp=144;
lq=384;
lphi=144;
altmin=80e3;
glat=42.45;
glon=143.4;
gridflag=1;
flagsource=1;


%% RUN THE GRID GENERATION CODE
if (~exist('xg'))
  xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
fprintf('Reading in source file...\n');
%[nsi,vs1i,Tsi,xgin,ns,vs1,Ts]=eq2dist(eqdir,simID,xg,file_format);
[nsi,vs1i,Tsi]=eq2dist(p,xg);


