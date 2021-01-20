function setup()
%% configure paths to work with MatGemini

cwd = fileparts(mfilename('fullpath'));
meta = jsondecode(fileread(fullfile(cwd, "libraries.json")));

gemini_matlab = getenv('MATGEMINI');
if isempty(gemini_matlab)
  gemini_matlab = fullfile(cwd, '../mat_gemini');
end

if ~isfolder(gemini_matlab)
  cmd = "git -C " + fullfile(cwd, '..') + " clone --recurse-submodules " + meta.matgemini.git;
  ret = system(cmd);

  if ret == 0 && ~isempty(meta.matgemini.tag)
    ret = system("git -C " + gemini_matlab + " checkout " + meta.matgemini.tag);
  end

  assert(ret==0, "Failed to download MatGemini")
end

run(fullfile(gemini_matlab, 'setup.m'))

end
