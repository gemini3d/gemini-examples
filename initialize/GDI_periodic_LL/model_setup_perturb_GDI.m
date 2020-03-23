cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils']);
addpath([gemini_root, filesep, 'vis']);


%% READ IN THE SIMULATION INFORMATION
ID=[gemini_root,'/../simulations/input/GDI_periodic_LL/'];
xg=readgrid([ID,'/inputs/']);
x1=xg.x1(3:end-2);    %trim ghost cells
x2=xg.x2(3:end-2);


%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
direc=ID;
filebase='GDI_periodic_LL';
filename=[filebase,'_ICs.dat'];
[ne,v1,Ti,Te,ns,Ts,vs1,simdate]=loadframe3Dcurvnoelec(direc,filename);
lsp=size(ns,4);


%% SCALE EQ PROFILES UP TO SENSIBLE BACKGROUND CONDITIONS
scalefact=5;
nsscale=zeros(size(ns));
for isp=1:lsp-1
    nsscale(:,:,:,isp)=scalefact*ns(:,:,:,isp);
end %for
nsscale(:,:,:,lsp)=sum(nsscale(:,:,:,1:6),4);   %enforce quasineutrality


%% GDI EXAMPLE (PERIODIC) INITIAL DENSITY STRUCTURE AND SEEDING
ell=10e3;           %a gradient scale length for patch/blob
x21=-220e3;         %location on one of the patch edges
x22=-140e3;         %other patch edge
nepatchfact=4;    %density increase factor over background

nsperturb=zeros(size(ns));
for isp=1:lsp-1
  for ix2=1:xg.lx(2)
    amplitude=randn(xg.lx(1),1,xg.lx(3));     %AWGN - note that can result in subtractive effects on density!!!
    amplitude=0.01*amplitude;                  %amplitude standard dev. is scaled to be 1% of reference profile
    
    nsperturb(:,ix2,:,isp)=nsscale(:,ix2,:,isp)+...                                             %original data
                nepatchfact*nsscale(:,ix2,:,isp)*(1/2*tanh((x2(ix2)-x21)/ell)-1/2*tanh((x2(ix2)-x22)/ell));    %patch, note offset in the x2 index!!!!

    if (ix2>200 & ix2<xg.lx(2)-200)         %do not apply noise near the edge (corrupts boundary conditions)
      nsperturb(:,ix2,:,isp)=nsperturb(:,ix2,:,isp)+amplitude.*nsscale(:,ix2,:,isp);
    end %if
    
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


%% WRITE OUT THE RESULTS TO A NEW FILE
outdir=ID;
dmy=[simdate(3),simdate(2),simdate(1)];
UTsec=simdate(4)*3600;
writedata(dmy,UTsec,nsperturb,vs1,Ts,outdir,'raw',64);

