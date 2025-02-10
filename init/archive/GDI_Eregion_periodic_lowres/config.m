%% gradient drift instability

out_dir = fullfile(tempdir, 'gdi_periodic_lowres');

gemini3d.run(out_dir)

gemini3d.plot(out_dir, 'png')
