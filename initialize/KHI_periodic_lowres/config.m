function config()
%% RISR PERIODIC KHI RUN

cwd = fileparts(mfilename('fullpath'));

cfg = read_config(cwd);

xg = makegrid_cart_3D(cfg);
%% interpolate
eq2dist(cfg, xg);
%% perturbation
perturb(cfg, xg)
%% E-field boundary conditions
efield(cfg, xg)
end