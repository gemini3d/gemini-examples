%SAPs grid
p.dtheta=15;
p.dphi=75;
p.lp=128;
p.lq=192;
p.lphi=64;
p.altmin=80e3;
p.glat=45;
p.glon=262.51;
p.gridflag=0;
p.flagsource=0;
p.iscurv=true;

%MATLAB GRID GENERATION
xg=gemini3d.grid.tilted_dipole(p);

%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
p.time = datetime(2013,5,18, 23,0,0);
p.activ=[124.6,138.5,6.1];
p.nmf=5e11;
p.nme=2e11;

dat = gemini3d.model.eqICs(p,xg);

%WRITE THE GRID AND INITIAL CONDITIONS
p.outdir = '~/simulations/input/SAPs3D_eq';

gemini3d.write.grid(p,xg)
gemini3d.write.state(p.outdir, dat);
