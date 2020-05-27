function config()
%% coarse grid for testing GDI development

cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, '../../setup.m'))

cfg = read_config(cwd);
%% generate grid
% should be able to include cfg.x2parms to generate nonuniform grid in
% x2...
cfg.x2parms=[200e3,0.5e3,9.5e3,10e3];
xg = makegrid_cart_3D(cfg);
%% Interpolate data to desired grid resolution
eq2dist(cfg, xg);
%% perturbation
perturb(cfg, xg)
%% E-field boundary conditions
Efield(cfg, xg)

end % function