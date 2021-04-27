%LOWRES 2D EXAMPLE FOR TESTING
xdist=40e3;    %eastward distance
ydist=600e3;    %northward distance
lxp=80;
lyp=1;
glat=67.11;
glon=212.95;
gridflag=0;
I=90;

%RUN THE GRID GENERATION CODE
if ~exist('xg', "var")
  xg= gemini3d.grid.cartesian(xdist,lxp,ydist,lyp,I,glat,glon);
end

eqdir='../../../simulations/2Dtest_eq/';
simID='ICI2';
[nsi,vs1i,Tsi,xgin,ns,vs1,Ts]= gemini3d.model.eq2dist(eqdir,simID,xg, file_format);
