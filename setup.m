function setup()
%% configure paths to work with MatGemini

cwd = fileparts(mfilename('fullpath'));
gemini_matlab = getenv('MATGEMINI');
if isempty(gemini_matlab)
  gemini_matlab = fullfile(cwd, '../mat_gemini');
end
if ~isfolder(gemini_matlab)
  cmd = "git -C " + fullfile(cwd, '..') + " clone --recurse-submodules https://github.com/gemini3d/mat_gemini";
  disp(cmd)
  ret = system(cmd);
  assert(ret==0, 'problem downloading Gemini Matlab functions')
end
run(fullfile(gemini_matlab, 'setup.m'))

end
