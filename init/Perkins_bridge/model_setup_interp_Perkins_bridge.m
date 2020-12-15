%MOORE, OK GRID (FULL)
dtheta=20;
dphi=10;
lp=512;
lq=256;
lphi=96;
altmin=80e3;
glat=39;
glon=262.51;
gridflag=0;


%MATLAB GRID GENERATION
if (~exist('xg'))
  %xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
  xg= gemini3d.grid.makegrid_tilteddipole_varx2_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end


eqdir=[geminiscripts_root,filesep,'../simulations/Perkins_eq/'];
simID='Perkins_bridge';
[nsi,vs1i,Tsi,xgin,ns,vs1,Ts] = gemini3d.model.eq2dist(eqdir,simID,xg);
