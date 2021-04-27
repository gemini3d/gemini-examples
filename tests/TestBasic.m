classdef TestBasic < matlab.unittest.TestCase

properties (TestParameter)
  name = {"risr2dew_eq", "risr2dns_eq", "risr3d_eq"}
end

properties
  TestData
end

methods(TestMethodSetup)
function setup_env(tc)
cwd = fileparts(mfilename('fullpath'));
tc.TestData.cwd = cwd;

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture('PreservingOnFailure', true)).Folder;

end
end

methods (Test)

function test_scenario(tc, name)
  runner(tc, name, tc.TestData.outdir)
end

end
end
