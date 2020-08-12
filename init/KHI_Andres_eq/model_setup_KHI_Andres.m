cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils'])
addpath([gemini_root, filesep, 'setup/gridgen'])
addpath([gemini_root, filesep, 'setup'])


%WHERE TO PUT THE GRID FILES, ETC.
outdir=[gemini_root, filesep, '../simulations/input/KHI_Andres_eq/'];


%RISR LOWRES GRID (CARTESIAN)
xdist=1.5e6;
ydist=1.5e6;
lxp=20;
lyp=20;
glat=78;
glon=15;
gridflag=0;
I=90;

%MATLAB GRID GENERATION
xg=makegrid_cart_3D_lowresx1(xdist,lxp,ydist,lyp,I,glat,glon);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT
%RISR
UT=18000/3600;
dmy=[20,2,2013];
activ=[150.0,150.0,50.0];


%USE OLD CODE FROM MATLAB MODEL
nmf=5e11;
nme=2e11;
[ns,Ts,vsx1]=eqICs3D(xg,UT,dmy,activ,nmf,nme);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS

simlabel='KHI_Andres_eq'
writegrid(xg,outdir);
time=UT*3600;   %doesn't matter for input files
writedata(dmy,time,ns,vsx1,Ts,outdir,simlabel);
