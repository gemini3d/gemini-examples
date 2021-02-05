%A LOW/MEDIUM RES TOHOKU 2D
p.dtheta=7.5;
p.dphi=12;
p.lp=512;
p.lq=512;
p.lphi=1;
p.altmin=80e3;
p.glat=42.45;
p.glon=143.4;
p.gridflag=1;
p.flagsource=1;

%RUN THE GRID GENERATION CODE
if ~exist('xg', 'var')
  xg = gemini3d.grid.tilted_dipole3d(p);
end

%ALTERNATIVELY WE MAY WANT TO READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
p.eq_dir= '~/simulations/tohoku20112D_eq/';
p.outdir='~/simulations/tohoku20112D_lowres/';
p.indat_size = '~/simulations/tohoku20112D_lowres/inputs/simsize.h5';
p.indat_grid = '~/simulations/tohoku20112D_lowres/inputs/simgrid.h5';
p.indat_file = '~/simulations/tohoku20112D_lowres/inputs/initial_conditions.h5';
p.file_format="h5";

dat = gemini3d.model.eq2dist(p,xg);
system(strcat("cp config.nml ",p.outdir,"/inputs/"));