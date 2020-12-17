%% A COARSE resolution tohoku eq grid
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
    xg= gemini3d.grid.tilted_dipole3d(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end %if


%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT, THESE ACTUALLY DON'T MATTER MUCH SO YOU CAN MAKE UP STUFF
p.UTsec0=5.75*3600;
p.ymd=[2011,3,11];
p.times=datetime([p.ymd,0,0,p.UTsec0]);
p.activ=[120,120,25];
p.nmf=5e11;
p.nme=2e11;
[ns,Ts,vsx1]=gemini3d.model.eqICs(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%% WRITE THE GRID AND INITIAL CONDITIONS
p.outdir='../../../simulations/tohoku20113D_eq_real32';
p.indat_size = '../../../simulations/tohoku20113D_eq_real32/inputs/simsize.h5';
p.indat_grid = '../../../simulations/tohoku20113D_eq_real32/inputs/simgrid.h5';
p.indat_file = '../../../simulations/tohoku20113D_eq_real32/inputs/initial_conditions.h5';
gemini3d.fileio.makedir(p.outdir);
gemini3d.write.grid(p,xg);
gemini3d.write.data(datetime([p.ymd,0,0,p.UTsec0]),ns,vsx1,Ts,p.indat_file);
system(strcat("cp config.nml ",p.outdir,"/inputs/"));