cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils'])
addpath([gemini_root, filesep, 'setup/gridgen'])
addpath([gemini_root, filesep, 'setup/'])
addpath([gemini_root, filesep, 'vis'])
addpath(['../../setup/gridgen'])


%MOORE, OK GRID (FULL)
%dtheta=25;
%dphi=35;
dtheta=20;
dphi=27.5;
%lp=275;
%lq=400;
%lphi=256;
lp=350;
lq=550;
lphi=288;
altmin=80e3;
glat=39;
glon=262.51;
gridflag=0;


%MATLAB GRID GENERATION
if (~exist('xg'))
  xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
  %xg=makegrid_tilteddipole_varx2_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end


eqdir='../../../simulations/mooreOK3D_eq/';
simID='mooreOK3D_medres';
[nsi,vs1i,Tsi,xgin,ns,vs1,Ts]=eq2dist(eqdir,simID,xg);
