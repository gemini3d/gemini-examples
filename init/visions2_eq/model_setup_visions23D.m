
%MOORE, OK GRID (FULL)
p.dtheta=25;
p.dphi=35;
p.lp=125;
p.lq=200;
p.lphi=40;
p.altmin=80e3;
p.glat=39;
p.glon=262.51;
p.gridflag=0;


%MATLAB GRID GENERATION
xg = gemini3d.grid.tilted_dipole3d(p);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
p.time = datetime(18,5,2013, 19, 45, 0);
p.activ = [124.6,138.5,6.1];
p.nmf=5e11;
p.nme=2e11;
ics = gemini3d.model.eqICs(p, xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
p.outdir = '~/simulations/input/mooreOK3D_eq/';
gemini3d.write.grid(p, xg);
gemini3d.write.state(p.outdir,ics);
