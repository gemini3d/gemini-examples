%% A modest resolution grid to test the global run with
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
    xg= gemini3d.setup.gridgen.makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end %if


%% Plot grid
flagsource=0;
neuinfo=struct();
plot_mapgrid(xg,flagsource,neuinfo);


%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT, THESE ACTUALLY DON'T MATTER MUCH SO YOU CAN MAKE UP STUFF
p.time = datetime(2011,3,11,5,45,0);
p.activ=[120,120,25];
p.nmf=5e11;
p.nme=2e11;
[ns,Ts,vsx1]= gemini3d.setup.eqICs3D(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%% WRITE THE GRID AND INITIAL CONDITIONS
p.simdir='../../../simulations/input/global_eq';
gemini3d.writegrid(p,xg);
gemini3d.writedata(p.time,ns,vsx1,Ts,p.simdir);