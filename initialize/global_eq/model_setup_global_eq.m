%cwd = fileparts(mfilename('fullpath'));
%gemini_root = [cwd, filesep, '../../../GEMINI'];
%addpath([gemini_root, filesep, 'script_utils'])
%addpath([gemini_root, filesep, 'setup/gridgen'])
%addpath([gemini_root, filesep, 'setup'])
%User must run gemini-matlab repo script setup.m to set paths


%% A HIGHRES TOHOKU INIT GRID
dtheta=15;
lp=256;
lq=384;
lphi=128;
dphi=365-365/lphi;
altmin=80e3;
glat=42.45;
glon=143.4;
gridflag=1;
flagsource=1;


%% MATLAB GRID GENERATION
if (~exist('xg'))
    xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end %if


%% Plot grid
flagsource=0;
neuinfo=struct();
plot_mapgrid(xg,flagsource,neuinfo);


%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT, THESE ACTUALLY DON'T MATTER MUCH SO YOU CAN MAKE UP STUFF
p.UTsec0=5.75*3600;
p.ymd=[2011,3,11];
p.activ=[120,120,25];
p.nmf=5e11;
p.nme=2e11;
[ns,Ts,vsx1]=eqICs3D(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%% WRITE THE GRID AND INITIAL CONDITIONS
p.simdir='../../../simulations/input/global_eq';
p.format='raw';
p.realbits=64;
writegrid(p,xg);
writedata(p.ymd,p.UTsec0,ns,vsx1,Ts,p.simdir,'raw',64);

