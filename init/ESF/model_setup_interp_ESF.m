%% Parameters for creating input files from given equilibrium run
cfg.eq_dir='~/simulations/ESF_eq/';
cfg.outdir='~/simulations/ESF_medres_noise_test_noise/inputs';
cfg.indat_size='~/simulations/ESF_medres_noise_test_noise/inputs/simsize.h5'
cfg.indat_grid='~/simulations/ESF_medres_noise_test_noise/inputs/simgrid.h5'
cfg.indat_file='~/simulations/ESF_medres_noise_test_noise/inputs/initial_conditions.h5'
cfg.nml='./config.nml';
cfg.file_format='h5';
mkdir(cfg.outdir);
system(['cp ',cfg.nml,' ',cfg.outdir])


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
[nsi,vs1i,Tsi]=gemini3d.setup.eq2dist(cfg,xg);
