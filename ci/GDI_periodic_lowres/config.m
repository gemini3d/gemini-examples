%% gradient drift instability
setenv('GEMINI_ROOT','~/Projects/GEMINI')
out_dir = fullfile("~/simulations/gdi_periodic_lowres_lagrangian");

gemini3d.model.setup("config.nml",out_dir)

%% OR have matlab run it automatically
% gemini3d.run(out_dir, 'dryrun', true)

% gemini3d.plot(out_dir, 'png')
