%% A COARSE resolution tohoku eq grid
p.dtheta=10;
p.dphi=15;
p.lp=128;
p.lq=384;
p.lphi=32;
p.altmin=80e3;
p.glat=42.45;
p.glon=143.4;
p.gridflag=1;
p.flagsource=1;


%% MATLAB GRID GENERATION
if ~exist('xg', 'var')
    xg= gemini3d.grid.tilted_dipole(p);
end %if


%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT, THESE ACTUALLY DON'T MATTER MUCH SO YOU CAN MAKE UP STUFF
p.times=datetime([p.ymd,0,0,p.UTsec0]);
p.activ=[120,120,25];
p.nmf=5e11;
p.nme=2e11;

dat = gemini3d.model.eqICs(p,xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%% WRITE THE GRID AND INITIAL CONDITIONS
p.outdir='~/simulations/tohoku20113D_eq';

gemini3d.write.grid(p,xg);
gemini3d.write.state(p.outdir, dat);
copyfile("config.nml", fullfile(p.outdir,"inputs"))
