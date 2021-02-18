% Open dipole grid in the cusp (Svalbard)
p.dtheta=11;
p.dphi=19;
p.lp=120;
p.lq=160;
p.lphi=1;
p.altmin=80e3;
p.glat=78.22;
p.glon=15.6;
p.gridflag=0;


% grid generation
if (~exist("xg","var"))
    xg = gemini3d.grid.tilted_dipole3d(p);
end %if


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
p.eq_dir="~/simulations/cusp_eq/";
p.indat_grid="~/simulations/cusp_softprecip_2D/inputs/simgrid.h5";
p.indat_size="~/simulations/cusp_softprecip_2D/inputs/simsize.h5";
p.indat_file="~/simulations/cusp_softprecip_2D/inputs/initial_conditions.h5";
p.outdir = '~/simulations/cusp_softprecip/';
p.file_format="h5";
ics=gemini3d.model.eq2dist(p,xg);
system(strcat("cp config.nml ",p.outdir,"/inputs/"));

% cusp precipitaiton input files
cfg=gemini3d.read.config(p.outdir);
pprec.E0precip=300;
pprec.prec_dir="~/simulations/cusp_softprecip_2D/inputs/precip/";
pprec.Qprecip=1;
pprec.Qprecip_background=0.01;
pprec.precip_latwidth=0.15;
pprec.precip_lonwidth=0.25;
pprec.times=cfg.times;
pprec.dtprec=5;
pprec.file_format="h5";
gemini3d.model.particles_BCs(pprec,xg);

% cusp FAC for top boundary
pE.Efield_latwidth=0.05;
pE.Efield_lonwidth=0.05;
pE.Jtarg=1.5e-6;
pE.E0_dir="~/simulations/cusp_softprecip/inputs/fields/";
pE.times=cfg.times;
pE.dtE0=10;
pE.file_format="h5";
gemini3d.model.Efield_BCs(pE,xg);