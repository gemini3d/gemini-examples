cwd = fileparts(mfilename('fullpath'));
if isempty(getenv('GEMINI_ROOT')), run([cwd, '/../../setup.m']), end

outdir = [getenv('GEMINI_ROOT'), '/../simulations/input/RISR_eq/'];

cfg = read_config(cwd);
%% MATLAB GRID GENERATION
xg = makegrid_cart_3D(cfg);

%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT

[ns,Ts,vsx1] = eqICs3D(cfg, xg);

%WRITE THE GRID AND INITIAL CONDITIONS

writegrid(cfg, xg);
writedata(cfg.ymd, cfg.UTsec0, ns, vsx1, Ts, outdir, cfg.file_format)
