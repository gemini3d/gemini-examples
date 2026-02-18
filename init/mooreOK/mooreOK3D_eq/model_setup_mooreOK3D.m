%MOORE, OK GRID (FULL), INTERHEMISPHERIC
p.dtheta=25;
p.dphi=35;
p.lp=125;
p.lq=425;
p.lphi=40;
p.altmin=80e3;
p.glat=39;
p.glon=262.51;
%gridflag=0;
p.gridflag=1;


%MATLAB GRID GENERATION
% xg = gemini3d.grid.tilted_dipole(p);
xg= gemini3d.grid.tilteddipole_varx2_3D(p);
%xg= gemin3d.grid.tilteddipole_varx2_oneside_3D_eq(p);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
UT=19.75;
p.time = datetime(2013,5,18, UT, 0, 0);
p.activ=[124.6,138.5,6.1];


%USE OLD CODE FROM MATLAB MODEL
p.nmf=5e11;
p.nme=2e11;

dat = gemini3d.model.eqICs(p, xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
p.outdir = '~/simulations/input/mooreOK3D_eq/';

gemin3d.write.grid(p,xg);

gemini3d.write.state(p.outdir,dat)
