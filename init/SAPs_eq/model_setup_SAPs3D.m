%SAPs grid
dtheta=15;
dphi=75;
lp=128;
lq=192;
lphi=64;
altmin=80e3;
glat=45;
glon=262.51;
gridflag=0;
flagsource=0;
iscurv=true;


%MATLAB GRID GENERATION
xg=gemini3d.setup.gridgen.makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
cfg.time = datetime(2013,5,18, 23,0,0);
cfg.activ=[124.6,138.5,6.1];
cfg.nmf=5e11;
cfg.nme=2e11;
[ns,Ts,vsx1]= gemini3d.setup.eqICs3D(cfg,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
outdir = [gemini_root, filesep, '../simulations/input/SAPs3D_eq/'];
simlabel='SAPs3D_eq';
gemini3d.write.grid(xg,outdir);
gemini3d.write.data(time,ns,vsx1,Ts,outdir,simlabel);
