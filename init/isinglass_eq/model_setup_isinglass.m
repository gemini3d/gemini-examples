%PFISR LOWRES GRID (CARTESIAN)
xdist=1200e3;    %eastward distance
ydist=600e3;    %northward distance
lxp=15;
lyp=15;
glat=67.11;
glon=212.95;
gridflag=0;
I=90;

%MATLAB GRID GENERATION
xg= gemini3d.grid.makegrid_cart_3D(xdist,lxp,ydist,lyp,I,glat,glon);

%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT
%%ISINGLASS B LAUNCH
cfg.activ=[76.5,79.3,31.5];
cfg.time = datetime(2017,3,2, 7.5,0,0);

%USE OLD CODE FROM MATLAB MODEL
cfg.nmf=5e11;
cfg.nme=2e11;
dat = gemini3d.model.eqICs(cfg, xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
outdir='~/simulations/raid/input/isinglass_eq_regen/'
gemini3d.write.grid(xg,outdir);
gemini3d.write.state(outdir, dat);
