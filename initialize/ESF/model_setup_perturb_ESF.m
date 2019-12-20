cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils']);
addpath([gemini_root, filesep, 'vis']);


%% READ IN THE SIMULATION INFORMATION
ID=[gemini_root,'/../simulations/input/ESF_medres/'];
xg=readgrid([ID]);
x1=xg.x1(3:end-2); x2=xg.x2(3:end-2); x3=xg.x3(3:end-2);
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
direc=ID;
filebase='ESF_medres';
filename=[filebase,'_ICs.dat'];
[ne,v1,Ti,Te,ns,Ts,vs1,simdate]=loadframe3Dcurvnoelec(direc,filename);
lsp=size(ns,4);


%%