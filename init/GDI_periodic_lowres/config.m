%% gradient drift instability

cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, '../../setup.m'))

out_dir = fullfile('~/sims', 'gdi_periodic_lowres');

gemini3d.model.setup(cwd, out_dir)
