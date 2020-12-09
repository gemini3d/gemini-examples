%% gradient drift instability
setenv('GEMINI_ROOT','~/Projects/GEMINI')
out_dir = fullfile("~/simulations/gdi_periodic_lowres_lagrangian");


%% "manual setup"
%cfg = gemini3d.read.config("./config.nml");
%cfg.outdir = gemini3d.fileio.expanduser(out_dir);
gemini3d.setup.model_setup("config.nml",out_dir)

%% OR have matlab run it automatically
% gemini3d.gemini_run(out_dir, 'dryrun', true)

% gemini3d.vis.gemini_plot(out_dir, 'png')
