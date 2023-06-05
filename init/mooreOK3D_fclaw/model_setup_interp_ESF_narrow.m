 %% Parameters for creating input files from given equilibrium run
p.eq_dir='~/simulations/raid/ESF_eq_tall/';
p.outdir='~/simulations/raid/ESF_dneu_narrow_lowres_tohoku/';

p.indat_size=[p.outdir,'/inputs/simsize.h5'];
p.indat_grid=[p.outdir,'/inputs/simgrid.h5'];
p.indat_file=[p.outdir,'/inputs/initial_conditions.h5'];

%% Equatorial grid
%p.dtheta=3.5;
p.dtheta=4.5;    % puts boundary farther away
p.dphi=34;
p.lp=256;
p.lq=256;
p.lphi=264;
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
