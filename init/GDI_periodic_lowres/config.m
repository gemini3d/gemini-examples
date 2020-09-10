%% gradient drift instability

out_dir = fullfile(tempdir, 'gdi_periodic_lowres');

gemini3d.gemini_run(out_dir)

gemini3d.vis.gemini_plot(out_dir, 'png')
