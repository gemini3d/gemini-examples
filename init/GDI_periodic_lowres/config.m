%% gradient drift instability

cwd = fileparts(mfilename('fullpath'));

params = struct();
% params.dryrun = true; % setup but not run

gemini3d.gemini_run(cwd, fullfile(tempdir, 'gdi_periodic_lowres'), params)
