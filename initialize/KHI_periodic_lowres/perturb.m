function perturb(cfg, xg)
% perturb plasma from initial_conditions file

narginchk(2,2)
validateattributes(cfg, {'struct'}, {'scalar'})
validateattributes(xg, {'struct'}, {'scalar'})
%% READ IN THE SIMULATION INFORMATION

x1=xg.x1(3:end-2);
x2=xg.x2(3:end-2);
x3=xg.x3(3:end-2);
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
dat = loadframe3Dcurvnoelec(cfg.indat_file);
lsp = size(dat.ns,4);

%% SCALE EQ PROFILES UP TO SENSIBLE BACKGROUND CONDITIONS
scalefact=2.75;
nsscale=zeros(size(dat.ns));
for isp=1:lsp-1
    nsscale(:,:,:,isp) = scalefact * dat.ns(:,:,:,isp);
end %for
nsscale(:,:,:,lsp) = sum(nsscale(:,:,:,1:6),4);   %enforce quasineutrality


%% APPLY THE PERTURBATION
v0=500;                   % background flow value, actually this will be turned into a shear in the Efield input file
densfact=10;              % factor by which the density increases over the shear region - see Keskinen, et al (1988)
voffset=2*v0/densfact;    % plays the role of the neutral wind from K88; prevents singularity - this form results from tweaking asymptotic value of ne to give a certain density jump
ell=1e3;                  % scale length for shear transition

nsperturb=zeros(size(dat.ns));
for isp=1:lsp
  for ix2=1:xg.lx(2)
    amplitude=randn(xg.lx(1),1,xg.lx(3));    %AGWN, note this can make density go negative so error checking needed below
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


%% WRITE OUT THE RESULTS TO A NEW FILE
ymd = dat.simdate(1:3);
UTsec = dat.simdate(4)*3600;
writedata(ymd, UTsec, nsperturb, dat.vs1, dat.Ts, cfg.outdir, cfg.file_format);

end % function
