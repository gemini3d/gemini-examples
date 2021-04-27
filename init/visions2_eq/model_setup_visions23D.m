% Open dipole grid in the cusp (Svalbard)
p.dtheta=12;
p.dphi=20;
p.lp=96;
p.lq=128;
p.lphi=54;
p.altmin=80e3;
p.glat=78.22;
p.glon=15.6;
p.gridflag=0;


%MATLAB GRID GENERATION
if (~exist("xg","var"))
    xg = gemini3d.grid.tilted_dipole(p);
end %if

%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
p.times = datetime(18,5,2013, 19, 45, 0);
p.activ = [124.6,138.5,6.1];
p.nmf=5e11;
p.nme=2e11;
p.indat_size="~/simulations/visions2_eq/inputs/simsize.h5";
p.indat_grid="~/simulations/visions2_eq/inputs/simgrid.h5";
ics = gemini3d.model.eqICs(p, xg);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
p.outdir = '~/simulations/visions2_eq/';
gemini3d.write.grid(p, xg);
gemini3d.write.state(p.outdir,ics);
copyfile("config.nml", fullfile(p.outdir,"inputs"));
