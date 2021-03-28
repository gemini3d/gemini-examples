%% EQuatorial grid
p.dtheta=5.75;
p.dphi=10;
p.lp=128;
p.lq=256;
p.lphi=48;
p.altmin=80e3;
p.glat=12;
p.glon=360-76.9;     %Jicamarca
p.gridflag=1;
p.flagsource=0;
p.iscurv=true;


%% MATLAB GRID GENERATION
xg= gemini3d.grid.tilted_dipole3d(p);
%xg=makegrid_tilteddipole_varx2_3D(p);
%xg=makegrid_tilteddipole_varx2_oneside_3D(p);


%% GEOGRAPHIC COORDINATES OF NEUTRAL SOURCE (OR GRID CENTER)
% % Iowa example
% neuinfo.sourcelat=38.9609;
% neuinfo.sourcelong=360-94.088;
% neuinfo.neugridtype=3;    %1 = Cartesian neutral grid (2D), 2 - axisymmetric (2D), 3 - 3D Cartesian
% neuinfo.zmin=0;
% neuinfo.zmax=375;
% neuinfo.xmin=-1200;
% neuinfo.xmax=1200;
% neuinfo.ymin=-1200;
% neuinfo.ymax=1200;
% neuinfo.rhomax=[];        %meaningless in 3D situations


%% FOR USERS INFO CONVERT SOURCE LOCATION TO GEOMAG for input file
% [sourcetheta,sourcephi]=geog2geomag(neuinfo.sourcelat,neuinfo.sourcelong);
% sourcemlat=90-sourcetheta*180/pi;
% sourcemlon=sourcephi*180/pi;

%% PLot the grid
%gemini3d.plot.grid(xg)

%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - the iowa event
%in this case
UT=5.25;
activ=[150,150,4];    %apparently this used the MSIS matlab defaults
time = datetime(datevec(datenum([2016,8,6, UT, 0, 0])));     %this is ridiculous

%% USE OLD CODE FROM MATLAB MODEL
p.outdir = '~/simulations/raid/ESF_eq/';
p.nmf=5e11;
p.nme=2e11;
p.times=time;
p.f107a=activ(1);
p.f107=activ(2);
p.Ap=activ(3);
p.indat_size=[p.outdir,'inputs/simsize.h5'];
p.indat_grid=[p.outdir,'inputs/simgrid.h5'];
p.indat_file=[p.outdir,'inputs/initial_conditions.h5'];
dat = gemini3d.model.eqICs(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%% WRITE THE GRID AND INITIAL CONDITIONS
gemini3d.write.grid(p,xg);
gemini3d.write.state(p.outdir,dat);
system(['cp config.nml ',p.outdir,'/']);