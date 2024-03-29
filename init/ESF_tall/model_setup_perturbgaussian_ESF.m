
%% READ IN THE SIMULATION INFORMATION
ID=['~/simulations/raid/ESF_tall/inputs/'];
xg= gemini3d.read.grid([ID]);
x1=xg.x1(3:end-2); x2=xg.x2(3:end-2); x3=xg.x3(3:end-2);
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
direc=ID;
filename='initial_conditions.h5';
dat= gemini3d.read.frame3Dcurvnoelec(fullfile(direc,filename));
cfg=gemini3d.read.config(direc);
v1=dat.v1;
ns=dat.ns;
Ts=dat.Ts;
vs1=dat.vs1;
ne=dat.ns(:,:,:,7);
simdate=datevec(dat.time);
lsp=size(ns,4);


%% Define a shape function for a perturbation on this grid
alt=xg.alt;
mlat=90-xg.theta*180/pi;
mlon=xg.phi*180/pi;
mlonmean=mean(mlon(:));
mlatmean=0;
altmean=310e3;
sigmlon=0.2;
sigmlat=2.5;
sigalt=15e3;
shapefn=exp(-(alt-altmean).^2/2/sigalt^2).*exp(-(mlon-mlonmean).^2/2/sigmlon^2).*exp(-(mlat-mlatmean).^2/2/sigmlat^2);
n1=ns(:,:,:,1);
n1perturb=n1-shapefn*0.25.*n1;


%% Visualize
ix1=lx1/2;

figure;
subplot(121);
pcolor(squeeze(mlon(ix1,1,:)),squeeze(alt(ix1,:,1)),squeeze(n1(ix1,:,:)))
shading flat;
axis xy;

subplot(122);
pcolor(squeeze(mlon(ix1,1,:)),squeeze(alt(ix1,:,1)),squeeze(n1perturb(ix1,:,:)))
shading flat;
axis xy;


%% Create a modified density variable for output
nsperturb=ns;
nsperturb(:,:,:,1)=n1perturb;
nsperturb(:,:,:,7)=sum(nsperturb(:,:,:,1:6),4);


dat.ns = nsperturb;
%% WRITE OUT THE RESULTS TO A NEW FILE
gemini3d.write.state(cfg.indat_file,dat);
