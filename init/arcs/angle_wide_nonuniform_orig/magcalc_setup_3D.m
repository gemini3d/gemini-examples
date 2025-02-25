run('~/Projects/mat_gemini/setup.m')

%SIMULATION LOCAITONS
simname='arcs_angle_wide_nonuniform_large_highresx1/';
basedir='~/simulations/raid/';
direc=[basedir,simname];
mkdir([direc,'/magplots']);    %store output plots with the simulation data


%UTseconds of the frame of interest
ymd_TOI=[2015,09,16];
UTsec_TOI=82923;


%SIMULATION META-DATA
cfg = gemini3d.read.config(direc);


%TABULATE THE SOURCE LOCATION
thdist=pi/2-cfg.sourcemlat*pi/180;    %zenith angle of source location
phidist=cfg.sourcemlon*pi/180;


%ANGULAR RANGE TO COVER FOR THE CALCLUATIONS (THIS IS FOR THE FIELD POINTS - SOURCE POINTS COVER ENTIRE GRID)
%dang=10;


%WE ALSO NEED TO LOAD THE GRID FILE
if (~exist('xg','var'))
  fprintf('Reading grid...\n');
  xg=gemini3d.read.grid(direc);
  lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
  lh=lx1;   %possibly obviated in this version - need to check
  if (lx3==1)
    flag2D=1;
    fprintf('2D meshgrid...\n')
    x1=xg.x1(3:end-2);
    x2=xg.x2(3:end-2);
    x3=xg.x3(3:end-2);
    [X2,X1]=meshgrid(x2(:),x1(1:lh)');
  else
    flag2D=0;
    fprintf('3D meshgrid...\n')
    x1=xg.x1(3:end-2);
    x2=xg.x2(3:end-2);
    x3=xg.x3(3:end-2);
    [X2,X1,X3]=meshgrid(x2(:),x1(1:lh)',x3(:));   %loadframe overwrites this (sloppy!) so redefine eeach time step
  end
end
fprintf('Grid loaded...\n');


%FIELD POINTS OF INTEREST (CAN/SHOULD BE DEFINED INDEPENDENT OF SIMULATION GRID)
ltheta=128;
if (~flag2D)
  lphi=128;
else
  lphi=1;
end
lr=128;

% thmin=min(xg.theta(:));
% thmax=max(xg.theta(:));
% phimin=min(xg.phi(:));
% phimax=max(xg.phi(:));
%rmin=6370e3+80e3;
%rmax=6370e3+350e3;
thmin=min(xg.theta(:));
thmax=max(xg.theta(:));
thavg=mean(xg.theta(:));
dtheta=thmax-thmin;
thmin=thavg-dtheta/12;
thmax=thavg+dtheta/12;
phimin=min(xg.phi(:));
phimax=max(xg.phi(:));
phiavg=mean(xg.phi(:));
dphi=phimax-phimin;
phimin=phiavg-dphi/12;
phimax=phiavg+dphi/12;
rmin=6370e3+80e3;
rmax=6370e3+150e3;

theta=linspace(thmin,thmax,ltheta);
if (~flag2D)
  phi=linspace(phimin,phimax,lphi);
else
  phi=phidist;
end
%r=(6370e3+500e3)*ones(ltheta,lphi);                          %use satellite orbital plane
r=linspace(rmin,rmax,lr);
[r,theta,phi]=ndgrid(r,theta,phi);

%CREATE AN INPUT FILE OF FIELD POINTS
xmag.R=r(:);
xmag.THETA=theta(:);
xmag.PHI=phi(:);
xmag.gridsize=[lr,ltheta,lphi];
%params.file_format="h5";
indat_grid=strcat(direc,"/inputs/magfieldpoints.h5");
gemini3d.write.maggrid(indat_grid,xmag)

% %CREATE AN INPUT FILE OF FIELD POINTS
% fid=fopen([direc,'/inputs/magfieldpoints.dat'],'w');
% fwrite(fid,numel(THETA),'integer*4');
% fwrite(fid,R(:),'real*8');
% fwrite(fid,THETA(:),'real*8');
% fwrite(fid,PHI(:),'real*8');
