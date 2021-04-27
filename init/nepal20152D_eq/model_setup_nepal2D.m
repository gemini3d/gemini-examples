%NEPAL 2015 GRID
p.dtheta=10;
p.dphi=16;
p.lp=256;
p.lq=750;
p.lphi=1;
p.altmin=80e3;
p.glat=35.75;
p.glon=84.73;
p.gridflag=1;

%MATLAB GRID GENERATION
xg= gemini3d.grid.tilted_dipole(p);

%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT
%NEPAL, 2015
p.activ=[136,125.6,0.5];

t0= 6+11/60;

time = datetime(2015, 4, 25, t0, 0, 0);

%USE OLD CODE FROM MATLAB MODEL
p.nmf=5e11;
p.nme=2e11;

dat = gemini3d.model.eqICs(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!

%WRITE THE GRID AND INITIAL CONDITIONS
p.outdir='~/zettergmdata/simulations/input/nepal20152D_eq';
gemini3d.write.grid(p,xg)

gemini3d.write.state(p.outdir, dat)
