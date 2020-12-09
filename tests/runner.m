function runner(name)
arguments
  name (1,1) string
end

cwd = fileparts(mfilename('fullpath'));

test_dir = fullfile(cwd, "../init", name);
%% setup new test data
p = gemini3d.read.config(test_dir);
p.outdir = fullfile(tempdir, name);

try
  gemini3d.setup.model_setup(p);
catch e
  if ~contains(e.identifier, 'file_not_found')
    rethrow(e)
  end
  fprintf(2, 'SKIP %s\n', name);
  return
end

end  % function
