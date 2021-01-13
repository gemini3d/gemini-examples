run("../../../mat_gemini/setup.m")

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
if ~exist('xg','var')
    xg= gemini3d.grid.tilted_dipole3d(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end %if


%% Plot grid
%flagsource=0;
%neuinfo=struct();
%plot_mapgrid(xg,flagsource,neuinfo);


%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT, THESE ACTUALLY DON'T MATTER MUCH SO YOU CAN MAKE UP STUFF
p.times = datetime(2011,3,11,5,45,0);
p.activ=[120,120,25];
p.nmf=5e11;
p.nme=2e11;
[ns,Ts,vsx1]= gemini3d.model.eqICs(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%% WRITE THE GRID AND INITIAL CONDITIONS
p.simdir="~/simulations/global_eq_testing";
p.indat_grid=fullfile(p.simdir,"/inputs/simgrid.h5");
p.indat_size=fullfile(p.simdir,"/inputs/simsize.h5");

gemini3d.write.grid(p,xg);
filename= fullfile(p.simdir, "inputs/initial_conditions.h5");
gemini3d.write.state(filename,p.times,ns,vsx1,Ts);


%% Copy over the config.nml
copyfile("config.nml", fullfile(p.simdir,"inputs"));
