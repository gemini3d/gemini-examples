%% Parameters for creating input files from given equilibrium run
p.eq_dir='~/simulations/ESF_eq/';
p.outdir='~/simulations/ESF_medres_noise_test/inputs';
p.nml='./config.nml';
p.file_format='h5';


%% Equatorial grid
dtheta=3.5;
dphi=2.5;
lp=192*3;
lq=256;
lphi=192*2;
altmin=80e3;
glat=8.35;
glon=360-76.9;     %Jicamarca
gridflag=1;
flagsource=0;
iscurv=true;


%% MATLAB GRID GENERATION
if (~exist('xg'))
    xg=gemini3d.setup.gridgen.makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end %if
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
fprintf('Reading in source file...\n');
[nsi,vs1i,Tsi]=gemini3d.setup.eq2dist(p,xg);
