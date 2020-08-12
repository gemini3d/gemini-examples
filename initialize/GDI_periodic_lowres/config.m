%% coarse grid for testing GDI development
cwd = fileparts(mfilename('fullpath'));

[cfg, xg] = model_setup(cwd, '~/simulations/gdi_periodic_lowres');

perturb(cfg, xg)
