%% A modest resolution grid to test the global run with
dtheta=15;
lp=128;
lq=256;
lphi=96;
dphi=360-360/lphi;
altmin=80e3;
glat=42.45;
glon=143.4;
gridflag=1;
flagsource=1;


%% MATLAB GRID GENERATION
if ~exist('xg', 'var')
    xg= gemini3d.grid.tilted_dipole3d(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
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
[ns,Ts,vsx1]= gemini3d.model.eqICs(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%% WRITE THE GRID AND INITIAL CONDITIONS
p.simdir='../../../simulations/input/EIA_eq';
p.file_format='raw';
gemini3d.write.grid(p,xg);
gemini3d.write.data(p.ymd,p.UTsec0,ns,vsx1,Ts,p.simdir,'raw',64);
