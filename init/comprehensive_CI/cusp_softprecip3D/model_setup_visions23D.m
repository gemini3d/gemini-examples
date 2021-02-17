% Open dipole grid in the cusp (Svalbard)
p.dtheta=11;
p.dphi=19;
p.lp=132;
p.lq=192;
p.lphi=64;
p.altmin=80e3;
p.glat=78.22;
p.glon=15.6;
p.gridflag=0;


% grid generation
if (~exist("xg","var"))
    xg = gemini3d.grid.tilted_dipole3d(p);
end %if


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
% p.times = datetime(18,5,2013, 19, 45, 0);
% p.activ = [124.6,138.5,6.1];
% p.nmf=5e11;
% p.nme=2e11;
% p.indat_size="~/simulations/visions2_eq/inputs/simsize.h5";
% p.indat_grid="~/simulations/visions2_eq/inputs/simgrid.h5";
% ics = gemini3d.model.eqICs(p, xg);
p.eq_dir="~/simulations/cusp_eq/";
p.indat_grid="~/simulations/cusp_softprecip/inputs/simgrid.h5";
p.indat_size="~/simulations/cusp_softprecip/inputs/simsize.h5";
p.indat_file="~/simulations/cusp_softprecip/inputs/initial_conditions.h5";
p.outdir = '~/simulations/cusp_softprecip/';
p.file_format="h5";
ics=gemini3d.model.eq2dist(p,xg);
system(strcat("cp config.nml ",p.outdir,"/inputs/"));

cfg=gemini3d.read.config(p.outdir);
pprec.E0precip=300;
pprec.prec_dir="~/simulations/cusp_softprecip/inputs/precip/";
pprec.Qprecip=1;
pprec.Qprecip_background=0.01;
pprec.mlat_mean=74;
pprec.mlon_mean=131;
pprec.precip_latwidth=0.15;
pprec.precip_lonwidth=0.25;
pprec.times=cfg.times;
pprec.dtprec=5;
pprec.file_format="h5";
gemini3d.model.particles_BCs(pprec,xg);