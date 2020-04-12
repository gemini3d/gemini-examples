cwd = fileparts(mfilename('fullpath'));
if ~exist('gemini_root', 'var'), run([cwd, '/../../setup.m']), end

cfg = read_config(cwd);

outdir = [gemini_root, '/../simulations/input/RISR_eq/'];

%% MATLAB GRID GENERATION
xg = makegrid_cart_3D(cfg);

%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT

[ns,Ts,vsx1] = eqICs3D(cfg, xg);

%WRITE THE GRID AND INITIAL CONDITIONS

writegrid(cfg, xg);
writedata(cfg.ymd, cfg.UTsec0, ns, vsx1, Ts, outdir, cfg.file_format)
