%% RISR PERIODIC KHI RUN

cwd = fileparts(mfilename('fullpath'));
%out_dir = fullfile(tempdir, 'khi_periodic_lowres_releasecandidate2');
out_dir = fullfile('~/simulations/', 'khi_periodic_lowres_releasecandidate2');
params = struct();
% params.dryrun = true; % setup but not run

gemini3d.setup.model_setup(cwd,out_dir)

%setenv('GEMINI_ROOT','~/Projects/GEMINI/')
%gemini3d.gemini_run(cwd, out_dir, params)
%gemini3d.vis.gemini_plot(out_dir, 'png')
