%EQ TOHOKU GRID 2D
dtheta=10;
dphi=12;
glat=42.45;
glon=143.40;
lp=256;
lq=750;
lphi=1;
altmin=80e3;
gridflag=1;

%MATLAB GRID GENERATION
xg= gemini3d.grid.tilted_dipole3d(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT
%%ISINGLASS B LAUNCH
cfg.time = datetime(2017,3,2, 7,30,0);
cfg.activ=[76.5,79.3,31.5];
cfg.nmf=5e11;
cfg.nme=2e11;
[ns,Ts,vsx1]= gemini3d.model.eqICs(cfg, xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
outdir = [gemini_root, filesep, '../simulations/input/tohoku20112D_eq/'];
simlabel='tohoku20112D_eq';
gemini3d.write.grid(xg,outdir);
gemini3d.write.data(time,ns,vsx1,Ts,outdir,simlabel);
