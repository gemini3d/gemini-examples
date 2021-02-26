%EQ TOHOKU GRID 2D
p.dtheta=10;
p.dphi=12;
p.glat=42.45;
p.glon=143.40;
p.lp=256;
p.lq=750;
p.lphi=1;
p.altmin=80e3;
p.gridflag=1;

%MATLAB GRID GENERATION
xg= gemini3d.grid.tilted_dipole3d(p);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT
%%ISINGLASS B LAUNCH
p.time = datetime(2017,3,2, 7,30,0);
p.activ=[76.5,79.3,31.5];
p.nmf=5e11;
p.nme=2e11;

dat = gemini3d.model.eqICs(p, xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
p.outdir = '~/simulations/input/tohoku20112D_eq/';

gemini3d.write.grid(p,xg);
gemini3d.write.state(p.outdir, dat);
