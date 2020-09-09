%% gradient drift instability
setenv('GEMINI_ROOT','~/Projects/GEMINI')
cwd = fileparts(mfilename('fullpath'));
%out_dir = fullfile(tempdir, 'gdi_periodic_lowres_lagrangian');
out_dir = fullfile('~/simulations/gdi_periodic_lowres_lagrangian');

params = struct();
params.dryrun = true; % setup but not run

gemini3d.gemini_run(cwd, out_dir, params)

if (~params.dryrun)
  gemini3d.vis.gemini_plot(out_dir, 'png')
end