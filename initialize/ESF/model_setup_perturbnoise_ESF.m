cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
% addpath([gemini_root, filesep, 'script_utils']);
% addpath([gemini_root, filesep, 'vis']);


%% READ IN THE SIMULATION INFORMATION
ID=[gemini_root,'/../simulations/ESF_medres_noise/inputs/'];
xg=readgrid([ID]);
x1=xg.x1(3:end-2); x2=xg.x2(3:end-2); x3=xg.x3(3:end-2);
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
direc=ID;
%filebase='ESF_medres';
%filename=[filebase,'_ICs.dat'];
filename='initial_conditions.h5';
dat=loadframe3Dcurvnoelec([direc,filesep,filename]);
ne=dat.ne;
v1=dat.v1;
Ti=dat.Ti;
Te=dat.Te;
ns=dat.ns;
Ts=dat.Ts;
vs1=dat.vs1;
simdate=dat.simdate;
lsp=size(ns,4);


nsperturb=dat.ns;
for isp=1:lsp-1
  for ix2=1:xg.lx(2)
    amplitude=randn(xg.lx(1),1,xg.lx(3));     %AWGN - note that can result in subtractive effects on density!!!
    amplitude=0.05*amplitude;                  %amplitude standard dev. is scaled to be 1% of reference profile

    if (ix2>10 && ix2<xg.lx(2)-10)         %do not apply noise near the edge (corrupts boundary conditions)
      nsperturb(:,ix2,:,isp) = nsperturb(:,ix2,:,isp) + amplitude .* nsperturb(:,ix2,:,isp);
    end %if

  end %for
end %for
nsperturb = max(nsperturb,1e4);                        %enforce a density floor (particularly need to pull out negative densities which can occur when noise is applied)
nsperturb(:,:,:,lsp) = sum(nsperturb(:,:,:,1:6),4);    %enforce quasineutrality


%% WRITE OUT THE RESULTS TO A NEW FILE
outdir=ID;
dmy=[simdate(3),simdate(2),simdate(1)];
UTsec=simdate(4)*3600;
file_format='h5';
realbits=64;
writedata(dmy,UTsec,nsperturb,vs1,Ts,outdir,file_format,realbits);


%% Visualize
alt=xg.alt;
mlat=90-xg.theta*180/pi;
mlon=xg.phi*180/pi;

ix1=lx1/2;

figure;
subplot(121);
imagesc(squeeze(mlon(ix1,1,:)),squeeze(alt(ix1,:,1)),squeeze(dat.ns(ix1,:,:,1)))
axis xy;

subplot(122);
imagesc(squeeze(mlon(ix1,1,:)),squeeze(alt(ix1,:,1)),squeeze(nsperturb(ix1,:,:,1)))
axis xy;
