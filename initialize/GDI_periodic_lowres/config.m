function config()
%% coarse grid for testing GDI development

cwd = fileparts(mfilename('fullpath'));
if isempty(getenv('GEMINI_ROOT')), run([cwd, '/../../setup.m']), end

cfg = read_config([cwd, '/config.nml']);
cfg.outdir = '~/simulations/GDI_periodic_lowres/inputs/';
cfg.realbits=64;
%% generate grid
xg = makegrid_cart_3D(cfg);
%% Interpolate data to desired grid resolution
eq2dist(cfg, xg);
%% perturbation
perturb(cfg, xg)
%% E-field boundary conditions
Efield(cfg, xg)

end % function
