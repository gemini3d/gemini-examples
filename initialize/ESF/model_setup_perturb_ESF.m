cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils']);
addpath([gemini_root, filesep, 'vis']);


%% READ IN THE SIMULATION INFORMATION
ID=[gemini_root,'/../simulations/input/ESF_medres/'];
xg=readgrid([ID,'inputs/']);
x1=xg.x1(3:end-2); x2=xg.x2(3:end-2); x3=xg.x3(3:end-2);
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
direc=ID;
filebase='ESF_medres';
filename=[filebase,'_ICs.dat'];
[ne,v1,Ti,Te,ns,Ts,vs1,simdate]=loadframe3Dcurvnoelec(direc,filename);
lsp=size(ns,4);


%% Define a shape function for a perturbation on this grid
alt=xg.alt;
mlat=90-xg.theta*180/pi;
mlon=xg.phi*180/pi;
mlonmean=mean(mlon(:));
mlatmean=0;
altmean=300e3;
sigmlon=0.25;
sigmlat=2.5;
sigalt=15e3;
shapefn=exp(-(alt-altmean).^2/2/sigalt^2).*exp(-(mlon-mlonmean).^2/2/sigmlon^2).*exp(-(mlat-mlatmean).^2/2/sigmlat^2);
n1=ns(:,:,:,1);
n1perturb=n1-shapefn*0.25.*n1;


%% Visualize
ix1=lx1/2;

figure;
subplot(121);
imagesc(squeeze(mlon(ix1,1,:)),squeeze(alt(ix1,:,1)),squeeze(n1(ix1,:,:)))
axis xy;

subplot(122);
imagesc(squeeze(mlon(ix1,1,:)),squeeze(alt(ix1,:,1)),squeeze(n1perturb(ix1,:,:)))
axis xy;


%% Create a modified density variable for output
nsperturb=ns;
nsperturb(:,:,:,1)=n1perturb;
nsperturb(:,:,:,7)=sum(nsperturb(:,:,:,1:6),4);


%% WRITE OUT THE RESULTS TO A NEW FILE
outdir=ID;
dmy=[simdate(3),simdate(2),simdate(1)];
UTsec=simdate(4)*3600;
writedata(dmy,UTsec,nsperturb,vs1,Ts,outdir,[filebase,'_perturb']);

