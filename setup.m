function setup()
%% configure paths to work with MatGemini

cwd = fileparts(mfilename("fullpath"));


gemini_matlab = getenv("MATGEMINI");
if isempty(gemini_matlab)
  gemini_matlab = fullfile(cwd, "../mat_gemini");
end

setup_file = fullfile(gemini_matlab, "setup.m");

if ~isfile(setup_file)
  meta = jsondecode(fileread(fullfile(cwd, "libraries.json")));

  cmd = "git -C " + fullfile(cwd, "..") + " clone --recurse-submodules " + meta.matgemini.git;
  ret = system(cmd);

  if ret == 0 && isfield(meta.matgemini, "tag") && ~isempty(meta.matgemini.tag)
    ret = system("git -C " + gemini_matlab + " checkout " + meta.matgemini.tag);
  end

  assert(ret==0, "Failed to download MatGemini")
end

run(setup_file)

end
