%% READ IN THE SIMULATION INFORMATION
ID=[gemini_root,'/../simulations/input/KHI_periodic_medres/'];
xg=gemini3d.read.grid([ID,'/inputs/']);
x1=xg.x1(3:end-2); x2=xg.x2(3:end-2); x3=xg.x3(3:end-2);
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
direc=ID;
filebase='KHI_periodic_medres';
filename=[filebase,'_ICs.dat'];
dat = gemini3d.read.frame3Dcurvnoelec(fullfile(direc,filename));
lsp=size(ns,4);


%% SCALE EQ PROFILES UP TO SENSIBLE BACKGROUND CONDITIONS
scalefact=2.75;
nsscale=zeros(size(ns));
for isp=1:lsp-1
    nsscale(:,:,:,isp)=scalefact*ns(:,:,:,isp);
end %for
nsscale(:,:,:,lsp)=sum(nsscale(:,:,:,1:6),4);   %enforce quasineutrality


%% APPLY THE PERTURBATION
densfact=10;              %factor by which the density increases over the shear region - see Keskinen, et al (1988)
v0=500;                   %background flow value, actually this will be turned into a shear in the Efield input file
voffset=2*v0/densfact;
ell=1e3;                  %scale length for shear transition

nsperturb=zeros(size(ns));
for isp=1:lsp
  for ix2=1:xg.lx(2)
    amplitude=randn(xg.lx(1),1,xg.lx(3));    %AGWM, note this can make density go negative so error checking needed below
    amplitude=0.01*amplitude;

    nsperturb(:,ix2,:,isp)=nsscale(:,ix2,:,isp).*(2*v0+voffset)./(-v0*tanh((x2(ix2))/ell)+v0+voffset);

    nsperturb(:,ix2,:,isp)=nsperturb(:,ix2,:,isp)+amplitude.*nsscale(:,ix2,:,isp);        %add some noise to seed instability
  end %for
end %for
nsperturb=max(nsperturb,1e4);                        %enforce a density floor (particularly need to pull out negative densities which can occur when noise is applied)
nsperturb(:,:,:,lsp)=sum(nsperturb(:,:,:,1:6),4);    %enforce quasineutrality


%% KILL OFF THE E-REGION WHICH WILL DAMP THE INSTABILITY (AND USUALLY ISN'T PRESENT IN PATCHES)
x1ref=150e3;     %where to start tapering down the density in altitude
dx1=10e3;
taper=1/2+1/2*tanh((x1-x1ref)/dx1);
for isp=1:lsp-1
   for ix3=1:xg.lx(3)
       for ix2=1:xg.lx(2)
           nsperturb(:,ix2,ix3,isp)=1e6+nsperturb(:,ix2,ix3,isp).*taper;
       end %for
   end %for
end %for
nsperturb(:,:,:,lsp)=sum(nsperturb(:,:,:,1:6),4);    %enforce quasineutrality


%% WRITE OUT THE RESULTS
outdir=ID;

gemini3d.write.state(cfg.indat_file,dat.time,nsperturb,vs1,Ts);
