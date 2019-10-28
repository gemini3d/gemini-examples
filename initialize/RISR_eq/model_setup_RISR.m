cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils'])
addpath([gemini_root, filesep, 'setup/gridgen'])
addpath([gemini_root, filesep, 'setup'])

outdir=[gemini_root, filesep, '../simulations/input/RISR_eq/'];

%RISR LOWRES GRID (CARTESIAN)
xdist=1.5e6;
ydist=1.5e6;
lxp=20;
lyp=20;
glat=75.6975;
glon=360.0-94.8322;
gridflag=0;
I=90;

%MATLAB GRID GENERATION
xg=makegrid_cart_3D_lowresx1(xdist,lxp,ydist,lyp,I,glat,glon);


%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT
UT_sec = 39600;
dmy = [23,1,2012];
activ = [86.5, 139.8, 3];
% [f107a, f107, ap] = activ;

%USE OLD CODE FROM MATLAB MODEL
nmf=5e11;
nme=2e11;
[ns,Ts,vsx1]=eqICs3D(xg, UT_hour / 3600,dmy,activ,nmf,nme);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS

simlabel='RISR_eq'
writegrid(xg,outdir);
writedata(dmy,UT_sec,ns,vsx1,Ts,outdir,simlabel);

