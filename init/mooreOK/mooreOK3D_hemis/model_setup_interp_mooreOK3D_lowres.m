
%MOORE, OK GRID (FULL)
p.dtheta=20;
p.dphi=27.5;
p.lp=192;
p.lq=384;
p.lphi=128;
p.altmin=80e3;
p.glat=39;
p.glon=262.51;
%gridflag=0;
p.gridflag=1;


%MATLAB GRID GENERATION
if ~exist('xg', 'var')
  xg= gemini3d.grid.tilted_dipole(p);
  %xg=makegrid_tilteddipole_varx2_3D(p);
  %xg=makegrid_tilteddipole_varx2_oneside_3D(p);
end


% %PLOT THE GRID IF DESIRED
% flagsource=0;
% sourcelat=glat;
% sourcelong=glon;
% neugridtype=[];
% zmin=[];
% zmax=[];
% rhomax=[];
% ha=plotgrid(xg,flagsource,sourcelat,sourcelong,neugridtype,zmin,zmax,rhomax);


%SAVE THE GRID DATA
p.eq_dir='~/simulations/mooreOK3D_hemis_eq/';
p.outdir='~/simulations/mooreOK3D_hemis_lowres';

gemini3d.model.eq2dist(p,xg)
