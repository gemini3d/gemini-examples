%% RISR PERIODIC KHI RUN

out_dir = fullfile('~/simulations/', 'khi_periodic_lowres_releasecandidate2');

%setenv('GEMINI_ROOT','~/Projects/GEMINI/')

gemini3d.run(out_dir, '.', 'dryrun', true)

%gemini3d.plot(out_dir, 'png')
