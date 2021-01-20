%% Iowa grid for AGU 2019
p.dtheta=20;
p.dphi=30;
p.lp=130;
p.lq=500;
p.lphi=48;
p.altmin=80e3;
p.glat=40;   %38.9609;
p.glon=360-94.088;
p.gridflag=1;
p.flagsource=1;
p.iscurv=true;


%% MATLAB GRID GENERATION
xg= gemini3d.grid.tilted_dipole3d(p);
%xg=makegrid_tilteddipole_varx2_3D(p);
%xg=makegrid_tilteddipole_varx2_oneside_3D(p);


%% GEOGRAPHIC COORDINATES OF NEUTRAL SOURCE (OR GRID CENTER)
% Iowa example
neuinfo.sourcelat=38.9609;
neuinfo.sourcelong=360-94.088;
neuinfo.neugridtype=3;    %1 = Cartesian neutral grid (2D), 2 - axisymmetric (2D), 3 - 3D Cartesian
neuinfo.zmin=0;
neuinfo.zmax=375;
neuinfo.xmin=-1200;
neuinfo.xmax=1200;
neuinfo.ymin=-1200;
neuinfo.ymax=1200;
neuinfo.rhomax=[];        %meaningless in 3D situations


%% FOR USERS INFO CONVERT SOURCE LOCATION TO GEOMAG
[sourcetheta,sourcephi]= gemini3d.geog2geomag(neuinfo.sourcelat,neuinfo.sourcelong);
sourcemlat=90-sourcetheta*180/pi;
sourcemlon=sourcephi*180/pi;


%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - the iowa event
%in this case
UT=2307/3600;
p.activ=[150,150,4];    %apparently this used the MSIS matlab defaults
p.times = datetime(2016,8,6,UT, 0,0);

%% USE OLD CODE FROM MATLAB MODEL
p.nmf=5e11;
p.nme=2e11;
dat = gemini3d.model.eqICs(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%% WRITE THE GRID AND INITIAL CONDITIONS
p.outdir = '~/simulations/input/iowa3D_eq/';

gemini3d.write.grid(p,xg);
gemini3d.write.state(p.outdir, dat);
