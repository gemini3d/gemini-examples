function setup()

cwd = fileparts(mfilename('fullpath'));
gemini_matlab = [cwd, '/../gemini-matlab'];
if ~isfolder(gemini_matlab)
  cmd = ['git -C ',cwd,'/../ clone https://github.com/gemini3d/gemini-matlab'];
  disp(cmd)
  ret = system(cmd);
  assert(ret==0, 'problem downloading Gemini Matlab functions')
end
run([gemini_matlab, '/setup.m'])

end
