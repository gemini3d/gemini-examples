% test a few setups
% for now, just tests that it doesn't error when run
%% lint
if exist('checkcode', 'file')
  checkcode_recursive([this, '/../'])
else
  fprintf(2, 'SKIP: lint check\n')
end
%% setup
this = fileparts(mfilename('fullpath'));
run([this, '/../setup.m'])
R = [this, '/../initialize'];

%% test2d_eq
model_setup([R, '/test2dew_eq'])
%% test2d_fang
try
  model_setup([R, '/test2dew_fang'])
catch e
  if ~strcmp(e.identifier, 'readgrid:file_not_found')
    rethrow(e)
  end
end
%% test2d_glow
try
  model_setup([R, '/test2dew_glow'])
catch e
  if ~strcmp(e.identifier, 'readgrid:file_not_found')
    rethrow(e)
  end
end
%% arcs_eq
model_setup([R, '/arcs_eq'])
%% arcs
try
  model_setup([R, '/arcs'])
catch e
  if ~strcmp(e.identifier, 'readgrid:file_not_found')
    rethrow(e)
  end
end
%% risr2dew_eq
model_setup([R, '/risr2dew_eq'])
%% risr2dns_eq
model_setup([R, '/risr2dns_eq'])
%% risr3d_eq
model_setup([R, '/risr3d_eq'])

disp('OK: gemini-examples generation checks')
