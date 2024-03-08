function runner(tc, name, outdir)
arguments
  tc (1,1) matlab.unittest.TestCase
  name (1,1) string
  outdir (1,1) string
end

cwd = fileparts(mfilename('fullpath'));

test_dir = fullfile(cwd, "../init", name);
%% setup new test data
p = gemini3d.read.config(test_dir);
tc.assumeNotEmpty(p, test_dir + " did not contain config.nml")
p.outdir = outdir;

try
  gemini3d.model.setup(p);
catch e
  tc.assumeSubstring(e.identifier, 'file_not_found')
  rethrow(e)
end

end
