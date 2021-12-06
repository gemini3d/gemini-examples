 %% Parameters for creating input files from given equilibrium run
p.eq_dir='~/simulations/ESF_eq_manual/';
p.outdir='~/simulations/ESF_M1_noiseonly/';

p.indat_size=[p.outdir,'/inputs/simsize.h5'];
p.indat_grid=[p.outdir,'/inputs/simgrid.h5'];
p.indat_file=[p.outdir,'/inputs/initial_conditions.h5'];

%% Equatorial grid
%p.dtheta=3.5;
p.dtheta=4.5;    % puts boundary farther away
p.dphi=34;
%p.lp=522;
p.lp=256;
p.lq=256;
%p.lphi=580;
p.lphi=288;
p.altmin=80e3;
p.glat=8.35;
p.glon=360-76.9;     %Jicamarca
p.gridflag=1;
p.flagsource=0;
p.iscurv=true;
p.file_format="h5";

%% MATLAB GRID GENERATION
if ~exist('xg', 'var')
  xg=gemini3d.grid.tilted_dipole(p);
end

%% READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
dat = gemini3d.model.eq2dist(p, xg);
system(['cp config.nml ',p.outdir,'/inputs/']);
