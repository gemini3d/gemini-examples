
%MOORE, OK GRID (FULL)
dtheta=25;
dphi=35;
lp=125;
lq=200;
lphi=40;
altmin=80e3;
glat=39;
glon=262.51;
gridflag=0;


%MATLAB GRID GENERATION
xg=gemini3d.setup.gridgen.makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
cfg.time = datetime(18,5,2013, 19, 45, 0);
cfg.activ = [124.6,138.5,6.1];
cfg.nmf=5e11;
cfg.nme=2e11;
[ns,Ts,vsx1] = gemini3d.setup.eqICs3D(cfg, xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
outdir = '../simulations/input/mooreOK3D_eq/';
simlabel='mooreOK3D_eq';
gemini3d.writegrid(xg,outdir);
gemini3d.writedata(time,ns,vsx1,Ts,outdir,simlabel);
