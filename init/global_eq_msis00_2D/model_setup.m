function model_setup(out_dir, plot, xg)
arguments
  out_dir string = string.empty
  plot (1,1) logical = false
  xg struct = struct.empty
end

run ~/Projects/mat_gemini-scripts/setup.m

cwd = fileparts(mfilename('fullpath'));
run(fullfile(cwd, "../../setup.m"))

%% A modest resolution grid to test the global run with
cfg = gemini3d.read.config(cwd);

cfg.dphi = 365 - 365 / cfg.lphi;

if ~isempty(out_dir)
  cfg.outdir = out_dir;
end

%cfg = stdlib.fileio.make_valid_paths(cfg);
%% MATLAB GRID GENERATION
p=cfg;
if isempty(xg)
  %xg = gemini3d.grid.tilted_dipole(cfg);
  xg=gemscr.grid.makegrid_tilteddipole_varx2_3D(p.dtheta,p.dphi,p.lp,p.lq,p.lphi,p.altmin,p.glat,p.glon,p.gridflag);
  gemini3d.write.grid(cfg, xg)
end

%% Plot grid
if plot
  gemini3d.plot.mapgrid(xg)
end

%% GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT
% THESE ACTUALLY DON'T MATTER MUCH SO YOU CAN MAKE UP STUFF
init_cond = gemini3d.model.eqICs(cfg, xg);

%% WRITE THE GRID AND INITIAL CONDITIONS
gemini3d.write.state(cfg.indat_file, init_cond, cfg.file_format);

%% Copy over the config.nml
copyfile("config.nml", fullfile(cfg.outdir,"inputs/"));

end
