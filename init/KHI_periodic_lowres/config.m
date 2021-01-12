%% RISR PERIODIC KHI RUN

out_dir = fullfile('~/sims', 'khi_periodic_lowres_releasecandidate2');

gemini3d.run(out_dir, '.')

gemini3d.plot(out_dir, 'png')
