% %% Set paths to other GEMINI repos
% cwd = fileparts(mfilename('fullpath'));
% gemini_root = [cwd, filesep, '../../../GEMINI'];
% addpath([gemini_root, filesep, 'vis'])
% addpath([gemini_root, filesep, 'script_utils']);
% addpath([gemini_root, filesep, 'setup/gridgen']);
% addpath([gemini_root, filesep, '../GEMINI-scripts/setup/gridgen']);
% addpath([gemini_root, filesep, 'setup']);
% geminiscripts_root = [cwd, filesep, '../../../GEMINI-scripts'];
% addpath([geminiscripts_root,filesep,'setup/gridgen']);


%% Parameters for creating input files from given equilibrium run
p.eqdir='~/simulations/ESF_eq/';
p.realbits=64;
p.outdir='~/simulations/ESF_medres';
p.nml='./config.nml';
p.file_format='h5';


%% Equatorial grid
dtheta=5.70;
dphi=5;
lp=256;
lq=384;
lphi=192;
altmin=80e3;
glat=12;
glon=360-76.9;     %Jicamarca
gridflag=1;
flagsource=0;
iscurv=true;


%% MATLAB GRID GENERATION
if (~exist('xg'))
    xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end %if
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
fprintf('Reading in source file...\n');
[nsi,vs1i,Tsi]=eq2dist(p,xg);
