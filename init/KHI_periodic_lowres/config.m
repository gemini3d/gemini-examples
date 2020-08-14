%% RISR PERIODIC KHI RUN

cwd = fileparts(mfilename('fullpath'));
out_dir = fullfile(tempdir, 'khi_periodic_lowres');
params = struct();
% params.dryrun = true; % setup but not run

gemini3d.gemini_run(cwd, out_dir, params)

gemini3d.vis.gemini_plot(out_dir, 'png')
