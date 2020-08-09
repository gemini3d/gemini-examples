% test a few setups
% for now, just tests that it doesn't error when run

this = fileparts(mfilename('fullpath'));
run(fullfile(this, '../setup.m'))

%% test2d_eq
runner('test2dew_eq')
%% test2d_fang
runner('test2dew_fang')
%% test2d_glow
runner('test2dew_glow')
%% arcs_eq
runner('arcs_eq')
%% arcs
runner('arcs')
%% risr2dew_eq
runner('risr2dew_eq')
%% risr2dns_eq
runner('risr2dns_eq')
%% risr3d_eq
runner('risr3d_eq')

disp('OK: gemini-examples generation checks')
