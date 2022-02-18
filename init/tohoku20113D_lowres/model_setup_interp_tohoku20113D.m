%A MEDIUM RES TOHOKU
p.dtheta=7.5;
p.dphi=12;
p.lp=192;
p.lq=512;
p.lphi=192;
p.altmin=80e3;
p.glat=42.45;
p.glon=143.4;
p.gridflag=1;
p.flagsource=1;
p.eq_dir='~/simulations/raid/tohoku3d_eq/';
p.nml='./config.ini';

%RUN THE GRID GENERATION CODE
if ~exist('xg', 'var')
  xg= gemini3d.grid.tilted_dipole(p);
end
%ALTERNATIVELY WE MAY WANT TO READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID

p.outdir= '~/simulations/raid/tohoku20113D_lowres_IVV';
p.indat_grid=[p.outdir,'/inputs/simgrid.h5'];
p.indat_size=[p.outdir,'/inputs/simsize.h5'];
p.indat_file=[p.outdir,'/inputs/initial_conditions.h5'];
p.file_format='h5';
dat = gemini3d.model.eq2dist(p,xg);
system(['cp ./config.nml ',p.outdir,'/inputs']);