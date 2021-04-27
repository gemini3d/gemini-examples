%MOORE, OK GRID (FULL)
p.dtheta=20;
p.dphi=27.5;
%lp=350;
%lq=550;
%lphi=288;
p.lp=256;
p.lq=256;
p.lphi=210;
p.altmin=80e3;
p.glat=39;
p.glon=262.51;
%gridflag=0;
p.gridflag=1;


%MATLAB GRID GENERATION
if ~exist('xg', 'var')
  %xg= gemini3d.grid.tilted_dipole(p);
  %xg=makegrid_tilteddipole_varx2_3D(p);
  xg = gemini3d.grid.tilteddipole_varx2_oneside_3D(p);
end


%PLOT THE GRID IF DESIRED
flagsource=0;
sourcelat=glat;
sourcelong=glon;
neugridtype=[];
zmin=[];
zmax=[];
rhomax=[];
gemini3d.plot.grid(xg,flagsource,sourcelat,sourcelong,neugridtype,zmin,zmax,rhomax)


%SAVE THE GRID DATA
p.eq_dir='~/simulations/mooreOK3D_eq/';
p.outdir ='~/simulations/mooreOK3D_medres';

dint = gemini3d.model.eq2dist(p, xg);
