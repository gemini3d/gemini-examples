function perturb_efieldBG(cfg,xg)
%Electric field boundary conditions and initial condition for KHI case

%% Error checking
narginchk(2,2)
validateattributes(cfg, {'struct'}, {'scalar'})
validateattributes(xg, {'struct'}, {'scalar'})

%% Sizes
x1=xg.x1(3:end-2);
x2=xg.x2(3:end-2);
x3=xg.x3(3:end-2);
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);

%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
dat = gemini3d.vis.loadframe3Dcurvnoelec(cfg.indat_file);
lsp = size(dat.ns,4);

%% SCALE EQ PROFILES UP TO SENSIBLE BACKGROUND CONDITIONS
scalefact=2*2.75;
nsscale=zeros(size(dat.ns));
for isp=1:lsp-1
    nsscale(:,:,:,isp) = scalefact * dat.ns(:,:,:,isp);
end %for
nsscale(:,:,:,lsp) = sum(nsscale(:,:,:,1:6),4);   %enforce quasineutrality


%% Apply the denisty perturbation as a jump and specified plasma drift variation (Earth-fixed frame)
% because this is derived from current density it is invariant with respect
% to frame of reference.
v0=-500;                                 % background flow value, actually this will be turned into a shear in the Efield input file
densfact=3;                              % factor by which the density increases over the shear region - see Keskinen, et al (1988)
ell=3.1513e3;                            % scale length for shear transition
vn=-v0*(densfact+1)./(densfact-1);
B1val=-50000e-9;

nsperturb=zeros(size(dat.ns));
for isp=1:lsp
  for ix2=1:xg.lx(2)
    % 3D noise
    %amplitude=randn(xg.lx(1),1,xg.lx(3));    %AGWN, note this can make density go negative so error checking needed below
    %amplitude=0.01*amplitude;

    % 2D noise
%     amplitude=randn(1,1,xg.lx(3));
%     amplitude=smooth(amplitude,10);
%     amplitude=reshape(amplitude,[1,1,lx3]);
%     amplitude=repmat(amplitude,[xg.lx(1),1,1]);
%     amplitude=0.01*amplitude;

    % single resonant perturbation
    x3dist=x3(end)-x3(1);
    nhar=2;
    lnoise=x3dist/nhar;
    knoise=2*pi/lnoise;
    amplitude=0.01*sin(knoise.*x3);
    amplitude=reshape(amplitude,[1,1,lx3]);
    amplitude=repmat(amplitude,[xg.lx(1),1,1]);

    nsperturb(:,ix2,:,isp)=nsscale(:,ix2,:,isp).*(vn-v0)./(v0*tanh((x2(ix2))/ell)+vn);
    nsperturb(:,ix2,:,isp)=nsperturb(:,ix2,:,isp)+amplitude.*nsscale(:,ix2,:,isp);        %add some noise to seed instability
  end %for
end %for
nsperturb=max(nsperturb,1e4);                        %enforce a density floor (particularly need to pull out negative densities which can occur when noise is applied)
nsperturb(:,:,:,lsp)=sum(nsperturb(:,:,:,1:6),4);    %enforce quasineutrality


%% Remove any residual E-region from the simulation
x1ref=220e3;     %where to start tapering down the density in altitude
dx1=10e3;
taper=1/2+1/2*tanh((x1-x1ref)/dx1);
for isp=1:lsp-1
   for ix3=1:xg.lx(3)
       for ix2=1:xg.lx(2)
           nsperturb(:,ix2,ix3,isp)=1e6+nsperturb(:,ix2,ix3,isp).*taper;
       end %for
   end %for
end %for
inds=find(x1<150e3);
nsperturb(inds,:,:,:)=1e3;
nsperturb(:,:,:,lsp)=sum(nsperturb(:,:,:,1:6),4);    %enforce quasineutrality
Phitop=zeros(lx2,lx3);
%Phitop=10*randn(lx2,lx3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
makedir(cfg.E0_dir);


%% CREATE ELECTRIC FIELD DATASET
E.llon=2048;
E.llat=2048;
% NOTE: cartesian-specific code
if lx2 == 1
  E.llon = 1;
elseif lx3 == 1
  E.llat = 1;
end
thetamin = min(xg.theta(:));
thetamax = max(xg.theta(:));
mlatmin = 90-thetamax*180/pi;
mlatmax = 90-thetamin*180/pi;
mlonmin = min(xg.phi(:))*180/pi;
mlonmax = max(xg.phi(:))*180/pi;

% add a 1% buff
latbuf = 1/100 * (mlatmax-mlatmin);
lonbuf = 1/100 * (mlonmax-mlonmin);
E.mlat = linspace(mlatmin-latbuf, mlatmax+latbuf, E.llat);
E.mlon = linspace(mlonmin-lonbuf, mlonmax+lonbuf, E.llon);
[E.MLON, E.MLAT] = ndgrid(E.mlon, E.mlat);


%% INTERPOLATE X2 COORDINATE ONTO PROPOSED MLON GRID
xgmlon=squeeze(xg.phi(1,:,1)*180/pi);
xgmlat=squeeze(90-xg.theta(1,1,:)*180/pi);
x2i=interp1(xgmlon,xg.x2(3:lx2+2),E.mlon,'linear','extrap');
x3i=interp1(xgmlat,xg.x3(3:lx3+2),E.mlat,'linear','extrap');


%% TIME VARIABLE (SECONDS FROM SIMULATION BEGINNING)
tmin = 0;
time = tmin:cfg.dtE0:cfg.tdur;
Nt = length(time);

%% SET UP TIME VARIABLES
UTsec = cfg.UTsec0 + time;     %time given in file is the seconds from beginning of hour
UThrs = UTsec / 3600;
E.expdate = cat(2, repmat(cfg.ymd(:)',[Nt, 1]), UThrs', zeros(Nt, 1), zeros(Nt, 1));
t = datenum(E.expdate);

%% CREATE DATA FOR BACKGROUND ELECTRIC FIELDS
if isfield(cfg, 'Exit')
  E.Exit = cfg.Exit * ones(E.llon, E.llat, Nt);
else
  E.Exit = zeros(E.llon, E.llat, Nt);
end
if isfield(cfg, 'Eyit')
  E.Eyit = cfg.Eyit * ones(E.llon, E.llat, Nt);
else
  E.Eyit = zeros(E.llon, E.llat, Nt);
end


%% CREATE DATA FOR BOUNDARY CONDITIONS FOR POTENTIAL SOLUTION
E.flagdirich=zeros(Nt,1);    %in principle can have different boundary types for different time steps...
E.Vminx1it = zeros(E.llon,E.llat, Nt);
E.Vmaxx1it = zeros(E.llon,E.llat, Nt);
%these are just slices
E.Vminx2ist = zeros(E.llat, Nt);
E.Vmaxx2ist = zeros(E.llat, Nt);
E.Vminx3ist = zeros(E.llon, Nt);
E.Vmaxx3ist = zeros(E.llon, Nt);

for it=1:Nt
    %ZEROS TOP CURRENT AND X3 BOUNDARIES DON'T MATTER SINCE PERIODIC



    %COMPUTE KHI DRIFT FROM APPLIED POTENTIAL
    vel3=zeros(E.llon, E.llat);
    for ilat=1:E.llat
        vel3(:,ilat)=v0*tanh(x2i./ell)-vn;
    end
    vel3=flipud(vel3);


    %CONVERT TO ELECTRIC FIELD
    E2slab=-vel3*B1val;
    E.Exit(:,:,it)=E2slab;
    E.Eyit(:,:,it)=zeros(E.llon,E.llat);
end


%% Write initial plasma state out to a file
gemini3d.write.data(dat.time, nsperturb, dat.vs1, dat.Ts, cfg.indat_file, cfg.file_format, Phitop);


%% Write electric field data to file
gemini3d.write.Efield(E, cfg.E0_dir, cfg.file_format)

end %function perturb_efield
