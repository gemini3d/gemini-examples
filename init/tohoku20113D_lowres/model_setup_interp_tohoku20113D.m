%A MEDIUM RES TOHOKU
p.dtheta=7.5;
p.dphi=12;
p.lp=96;
p.lq=284;
p.lphi=96;
p.altmin=80e3;
p.glat=42.45;
p.glon=143.4;
p.gridflag=1;
p.flagsource=1;


%RUN THE GRID GENERATION CODE
if ~exist('xg', 'var')
  xg= gemini3d.grid.tilted_dipole(p);
end
%ALTERNATIVELY WE MAY WANT TO READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID

p.eq_dir= '~/simulations/tohoku20113D_eq/';
p.outdir= '~/simulations/input/tohoku20113D_lowres';
dat = gemini3d.model.eq2dist(p,xg);
