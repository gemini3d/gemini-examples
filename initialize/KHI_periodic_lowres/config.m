function config()
%% RISR PERIODIC KHI RUN

cwd = fileparts(mfilename('fullpath'));

cfg = read_config(cwd);

cfg.x2parms=[200e3,0.9e3,10.1e3,10e3];
xg = makegrid_cart_3D(cfg);
%% interpolate
eq2dist(cfg, xg);
%% perturbation
perturb(cfg, xg)
%% E-field boundary conditions
efield(cfg, xg)
end