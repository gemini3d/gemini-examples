cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, '/../gemini-matlab'];
assert(isfolder(gemini_root), ['GEMINI Matlab code directory not found: ',gemini_root])

cd(gemini_root)
setup()
cd(cwd)
