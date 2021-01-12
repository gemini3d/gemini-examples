function runner(tc, name, outdir)
arguments
  tc (1,1) matlab.unittest.TestCase
  name (1,1) string
  outdir string = fullfile(tempdir, name)
end

cwd = fileparts(mfilename('fullpath'));

test_dir = fullfile(cwd, "../init", name);
%% setup new test data
p = gemini3d.read.config(test_dir);
tc.verifyNotEmpty(p, "did not contain config.nml")
p.out_dir = outdir;

try
  gemini3d.model.setup(p);
catch e
  if ~contains(e.identifier, 'file_not_found')
    rethrow(e)
  end
  fprintf(2, 'SKIP %s\n', name);
  return
end

end  % function
