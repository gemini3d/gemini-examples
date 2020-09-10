%% gradient drift instability
setenv('GEMINI_ROOT','~/Projects/GEMINI')
out_dir = fullfile('~/simulations/gdi_periodic_lowres_lagrangian');

gemini3d.gemini_run(out_dir, 'dryrun', true)

% gemini3d.vis.gemini_plot(out_dir, 'png')
