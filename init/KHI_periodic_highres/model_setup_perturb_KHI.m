cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils'])
addpath([gemini_root, filesep, 'vis'])

%% READ IN THE SIMULATION INFORMATION
ID='~/zettergmdata/simulations/input/KHI_periodic_highres_fileinput/';
xg=readgrid(ID);


%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
direc=ID;
filebase='KHI_periodic_highres_fileinput';
filename=[filebase,'_ICs.dat'];
[ne,v1,Ti,Te,ns,Ts,vs1,simdate]=loadframe3Dcurvnoelec(direc,filename);
lsp=size(ns,4);

%% KHI EXAMPLE PARAMETERS
v0=500d0;
vn=500d0;
voffset=100d0;

sigx2=770e0;      %from Keskinen, 1988 growth rate formulas
meanx3=0e3;
sigx3=20e3;
meanx2=0e0;


%% CREATE THE DENSITY PERTURBATIONS
for isp=1:lsp
  for ix2=1:xg.lx(2)
    amplitude=rand(xg.lx(1),1,xg.lx(3));
    amplitude=0.025*amplitude;
    nsperturb(:,ix2,:,isp)=ns(:,ix2,:,isp).*(v0+vn+voffset)./(-v0*tanh((xg.x2(2+ix2))/sigx2)+vn+voffset)+ ...
                          amplitude.*10e0.*ns(:,ix2,:,isp);
  end
end


%% WRITE OUT THE RESULTS TO A NEW INPUT FILE
outdir=ID;
dmy=[simdate(3),simdate(2),simdate(1)];
UTsec=simdate(4)*3600;
writedata(dmy,UTsec,nsperturb,vs1,Ts,outdir,[filebase,'_perturb']);
