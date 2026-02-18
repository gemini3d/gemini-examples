%MOORE, OK GRID (FULL), INTERHEMISPHERIC
dtheta=25;
dphi=35;
lp=125;
lq=425;
lphi=48;
altmin=80e3;
glat=39;
glon=262.51;
%gridflag=0;
gridflag=1;


%MATLAB GRID GENERATION
%xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
%xg=makegrid_tilteddipole_varx2_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
xg= gemini3d.grid.makegrid_tilteddipole_varx2_3D_eq(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);


%PLOT THE GRID IF DESIRED
flagsource=1;
sourcelat=35.3;
sourcelong=360-97.7;
neugridtype=0;            %1 = Cartesian neutral grid, anything else - axisymmetric
zmin=0;
zmax=660;
rhomax=1800;
gemini3d.plot.grid(xg,flagsource,sourcelat,sourcelong,neugridtype,zmin,zmax,rhomax)


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
UT=19.75;
p.time = datetime(2013,5,18, UT, 0,0);
p.activ=[124.6,138.5,6.1];


%USE OLD CODE FROM MATLAB MODEL
p.nmf=5e11;
p.nme=2e11;
dat = gemini3d.model.eqICs(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
p.outdir = '~/simulations/input/mooreOK3D_hemis_eq/';

gemini3d.write.grid(p,xg);
gemini3d.write.state(p.outdir,dat);
