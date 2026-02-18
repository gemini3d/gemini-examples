
%WHERE TO PUT THE GRID FILES, ETC.
outdir= fullfile(gemini_root, '../simulations/input/KHI_Andres_eq/');


%RISR LOWRES GRID (CARTESIAN)
xdist=1.5e6;
ydist=1.5e6;
lxp=20;
lyp=20;
glat=78;
glon=15;
gridflag=0;
I=90;

%MATLAB GRID GENERATION
xg= gemini3d.grid.makegrid_cart_3D_lowresx1(xdist,lxp,ydist,lyp,I,glat,glon);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT
%RISR
cfg.activ=[150.0,150.0,50.0];
cfg.time = datetime(2013,2,20, 0, 0, 18000);

%USE OLD CODE FROM MATLAB MODEL
cfg.nmf=5e11;
cfg.nme=2e11;
dat = gemini3d.model.eqICs(cfg, xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS

gemini3d.write.grid(xg, outdir);
gemini3d.write.state(outdir, dat);
