cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils'])
addpath([gemini_root, filesep, 'setup/gridgen'])
addpath([gemini_root, filesep, 'setup'])
addpath([gemini_root, filesep, 'vis'])

mlonctr=259.0423;
mlatctr=66.7615;
thetactr=pi/2-mlatctr*pi/180;
phictr=mlonctr*pi/180;

%PFISR LOWRES GRID (CARTESIAN)
xdist=280e3;    %eastward distance
ydist=155e3;    %northward distance
%lxp=256;
%lyp=256;
lxp=128;
lyp=128;
[glat,glon]=geomag2geog(thetactr,phictr)
%glat=67.11;
%glon=212.95;
gridflag=0;
I=90;


%RUN THE GRID GENERATION CODE
if (~exist('xg'))
  xg=makegrid_cart_3D(xdist,lxp,ydist,lyp,I,glat,glon);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


eqdir='../../../simulations/isinglass_eq/';
distdir='../../../simulations/isinglass_clayton_flight/';
simID='isinglass_clayton_flight';
[nsi,vs1i,Tsi,xgin,ns,vs1,Ts]=eq2dist(eqdir,distdir,simID,xg);
