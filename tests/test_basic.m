% test a few setups
% for now, just tests that it doesn't error when run

this = fileparts(mfilename('fullpath'));
run([this, '/../setup.m'])

%% test2d_eq
model_setup([this, '/../initialize/test2d_eq'])
%% test2d_fang
try
  model_setup([this, '/../initialize/test2d_fang'])
catch e
  if ~strcmp(e.identifier, 'loadframe:file_not_found')
    rethrow(e)
  end
end
%% test2d_glow
try
  model_setup([this, '/../initialize/test2d_glow'])
catch e
  if ~strcmp(e.identifier, 'loadframe:file_not_found')
    rethrow(e)
  end
end
