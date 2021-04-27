%% Parameters for EQ and new simulation
p.eq_dir='~/simulations/tohoku20113D_eq/';
p.outdir='~/simulations/input/tohoku20113D_medres';

%% A LOW/MEDIUM RES TOHOKU
p.dtheta=7.5;
p.dphi=12;
p.lp=192;
p.lq=512;
p.lphi=144;
p.altmin=80e3;
p.glat=42.45;
p.glon=143.4;
p.gridflag=1;
p.flagsource=1;

%% RUN THE GRID GENERATION CODE
if ~exist('xg', 'var')
  xg=getmini3d.grid.tilted_dipole(p);
end

dat = gemini3d.model.eq2dist(p,xg);
