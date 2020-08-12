% cwd = fileparts(mfilename('fullpath'));
% gemini_root = [cwd, filesep, '../../../GEMINI'];
% addpath([gemini_root, filesep, 'script_utils'])
% addpath([gemini_root, filesep, 'setup/gridgen'])
% addpath([gemini_root, filesep, 'setup'])


%% A HIGHRES TOHOKU INIT GRID
dtheta=10;
dphi=15;
lp=128;
lq=384;
lphi=32;
altmin=80e3;
glat=42.45;
glon=143.4;
gridflag=1;
flagsource=1;


%% MATLAB GRID GENERATION
if (~exist('xg'))
    xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end %if


%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT, THESE ACTUALLY DON'T MATTER MUCH SO YOU CAN MAKE UP STUFF
p.UTsec0=5.75;
p.ymd=[2011,3,11];
p.activ=[120,120,25];
p.nmf=5e11;
p.nme=2e11;
[ns,Ts,vsx1]=eqICs3D(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%% WRITE THE GRID AND INITIAL CONDITIONS
p.simdir='../../../simulations/input/tohoku20113D_eq';
p.format='raw';

writegrid(p,xg);
writedata(p.ymd,p.UTsec0,ns,vsx1,Ts,p.simdir,'raw',64);
