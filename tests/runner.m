function runner(name)

narginchk(1,1)
validateattributes(name, {'char'}, {'vector'}, mfilename, 'test name', 1)

cwd = fileparts(mfilename('fullpath'));

test_dir = fullfile(cwd, '../initialize', name);
%% setup new test data
p = read_config(test_dir);
p.outdir = fullfile(tempdir, name);

try
  model_setup(p);
catch e
  if ~strcmp(e.identifier, 'get_frame_filename:file_not_found')
    rethrow(e)
  end
  fprintf(2, 'SKIP %s\n', name);
  return
end

end  % function
