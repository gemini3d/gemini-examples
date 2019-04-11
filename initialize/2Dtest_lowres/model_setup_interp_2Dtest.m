%LOWRES 2D EXAMPLE FOR TESTING
xdist=200e3;    %eastward distance
ydist=600e3;    %northward distance
lxp=40;
lyp=1;
glat=67.11;
glon=212.95;
gridflag=0;
I=90;


%ADD PATHS FOR FUNCTIONS
cwd = fileparts(mfilename('fullpath'));
addpath([cwd, filesep, '..', filesep,'..',filesep,'..',filesep,'GEMINI/script_utils']);
addpath([cwd, filesep, '..', filesep,'..',filesep,'..',filesep,'GEMINI/setup']);
addpath([cwd, filesep, '..', filesep,'..',filesep,'..',filesep,'GEMINI/setup',filesep,'gridgen'])
addpath([cwd, filesep, '..', filesep,'..',filesep,'..',filesep,'GEMINI/vis']);


%RUN THE GRID GENERATION CODE
if (~exist('xg'))
  xg=makegrid_cart_3D_lowresx1(xdist,lxp,ydist,lyp,I,glat,glon);
end

eqdir='../../../simulations/2Dtest_lowres_eq/';
distdir='../../../simulations/input/2Dtest_lowres/';
simID='2Dtest_lowres';
[nsi,vs1i,Tsi,xgin,ns,vs1,Ts]=eq2dist(eqdir,simID,xg);

