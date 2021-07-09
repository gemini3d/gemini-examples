run ~/Projects/mat_gemini-scripts/setup.m

%MOORE, OK GRID (FULL)
p.dtheta=25;
p.dphi=35;
p.lp=125;
p.lq=200;    %will be ignored if using nonunifrom x2
p.lphi=96;
p.altmin=80e3;
p.glat=39;
p.glon=262.51;
p.gridflag=0;


%MATLAB GRID GENERATION, old-style eventually needs to be updated
%xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
xg=gemscr.grid.makegrid_tilteddipole_varx2_3D(p.dtheta,p.dphi,p.lp,p.lq,p.lphi,p.altmin,p.glat,p.glon,p.gridflag);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
UT=19.75;
p.times = datetime([2013,5,18, 0, 0, UT*3600]);
p.activ=[124.6,138.5,6.1];


%USE OLD CODE FROM MATLAB MODEL
p=gemini3d.read.config("./config.nml");    % MSIS needs a populated config struct.
p.nmf=5e11;
p.nme=2e11;
dat = gemini3d.model.eqICs(p, xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
p.outdir = '~/simulations/raid/Perkins_eq/';

gemini3d.write.grid(p,xg)
gemini3d.write.state(p.outdir, dat)
