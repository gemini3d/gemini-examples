function setup()
%% configure paths to work with MatGemini

cwd = fileparts(mfilename("fullpath"));


gemini_matlab = getenv("MATGEMINI");
if isempty(gemini_matlab)
  gemini_matlab = fullfile(cwd, "../mat_gemini");
end

setup_file = fullfile(gemini_matlab, "setup.m");

if ~isfile(setup_file)
  error("Set environment variable MATGEMINI to the path where https://github.com/gemini3d/mat_gemini resides on your computer.")
end

run(setup_file)

end
