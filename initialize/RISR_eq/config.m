function config()

cwd = fileparts(mfilename('fullpath'));
if isempty(getenv('GEMINI_ROOT')), run([cwd, '/../../setup.m']), end

outdir = '~/simulations/RISR_eq/inputs/';

cfg = read_config([cwd, '/config.nml']);
makedir(outdir)
copy_file(cfg.nml, outdir)
%% MATLAB GRID GENERATION
xg = makegrid_cart_3D(cfg);

writegrid(cfg, xg);
%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT

[ns,Ts,vsx1] = eqICs3D(cfg, xg);

writedata(cfg.ymd, cfg.UTsec0, ns, vsx1, Ts, outdir, cfg.file_format)

end % function
