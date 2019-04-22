cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils'])
addpath([gemini_root, filesep, 'setup/gridgen'])
addpath([gemini_root, filesep, 'setup/'])
addpath([gemini_root, filesep, 'vis'])
geminiscripts_root = [cwd, filesep, '../../../GEMINI-scripts'];
addpath([geminiscripts_root,filesep,'setup/gridgen']);


%MOORE, OK GRID (FULL)
dtheta=20;
dphi=27.5;
lp=350;
lq=384;
lphi=192;
altmin=80e3;
glat=39;
glon=262.51;
gridflag=0;


%MATLAB GRID GENERATION
%{
if (~exist('xg'))
  %xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
  xg=makegrid_tilteddipole_varx2_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end
%}
eqdir=['~/SDHCcard/Perkins_bridge/'];
if (~exist('xg'))
    xg=readgrid([eqdir,'inputs/']);
end



%INTERPOLATE ONTO THE NEW GRID
%eqdir=[geminiscripts_root,filesep,'../simulations/Perkins_bridge/'];
simID='Perkins';
[nsi,vs1i,Tsi,xg,ns,vs1,Ts]=eq2dist(eqdir,simID,xg);


%NOW ADD SOME NOISE TO SEED PERKINS INSTABILITY

