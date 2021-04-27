%% A modest resolution grid to test the global run with
p.dtheta=15;
p.lp=128;
p.lq=256;
p.lphi=96;
p.dphi=360-360/lphi;
p.altmin=80e3;
p.glat=42.45;
p.glon=143.4;
p.gridflag=1;
p.flagsource=1;


%% MATLAB GRID GENERATION
if ~exist('xg', 'var')
  xg= gemini3d.grid.tilted_dipole(p);
end %if

%% Plot grid
gemini3d.plot.mapgrid(xg);

%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT, THESE ACTUALLY DON'T MATTER MUCH SO YOU CAN MAKE UP STUFF
p.times = datetime(2011, 3, 11, 5.75, 0, 0);
p.activ=[120,120,25];
p.nmf=5e11;
p.nme=2e11;

dat = gemini3d.model.eqICs(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!

%% WRITE THE GRID AND INITIAL CONDITIONS
p.outdir='~/simulations/input/EIA_eq';
gemini3d.write.grid(p,xg);
gemini3d.write.state(p.outdir,dat);
