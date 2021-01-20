%% Parameters for creating input files from given equilibrium run
p.eq_dir='~/simulations/ESF_eq/';
p.outdir='~/simulations/ESF_medres_noise_test_noise';
p.indat_size='inputs/simsize.h5';
p.indat_grid='inputs/simgrid.h5';
p.indat_file='inputs/initial_conditions.h5';

%% Equatorial grid
p.dtheta=3.5;
p.dphi=2.5;
p.lp=192*3;
p.lq=256;
p.lphi=192*2;
p.altmin=80e3;
p.glat=8.35;
p.glon=360-76.9;     %Jicamarca
p.gridflag=1;
p.flagsource=0;
p.iscurv=true;


%% MATLAB GRID GENERATION
if ~exist('xg', 'var')
  xg=gemini3d.grid.tilted_dipole3d(p);
end

%% READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
dat = gemini3d.model.eq2dist(p, xg);
