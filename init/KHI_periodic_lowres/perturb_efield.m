function perturb_efield(cfg,xg)
%Electric field boundary conditions and initial condition for KHI case
arguments
  cfg (1,1) struct
  xg (1,1) struct
end

params = struct(...
  'v0', -500, ...       % background flow value, actually this will be turned into a shear in the Efield input file
  'densfact', 3, ...    % factor by which the density increases over the shear region - see Keskinen, et al (1988)
  'ell', 3.1513e3, ...  % scale length for shear transition
  'B1val', -50000e-9, ...
  'x1ref', 220e3, ...     %where to start tapering down the density in altitude
  'dx1', 10e3);

params.vn = -params.v0*(params.densfact+1) ./ (params.densfact-1);

%% Sizes
x1=xg.x1(3:end-2);
x2=xg.x2(3:end-2);
lx2=xg.lx(2);
lx3=xg.lx(3);

%% LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
dat = gemini3d.read.frame3Dcurvnoelec(cfg.indat_file);

nsscale = init_profile(xg, dat);

%% Apply the denisty perturbation as a jump and specified plasma drift variation (Earth-fixed frame)
dat.ns = perturb_density(xg, dat, nsscale, x1, x2, params);

%% compute initial potential, background
dat.Phitop = potential_bg(x2, lx2, lx3, params);

%% Write initial plasma state out to a file
gemini3d.write.state(cfg.indat_file, dat, cfg.file_format)

%% Electromagnetic parameter inputs
create_Efield(cfg, xg, params)

end %function perturb_efield


function nsscale = init_profile(xg, dat)

lsp = size(dat.ns, 4);

%% Choose a single profile from the center of the eq domain
ix2=floor(xg.lx(2)/2);
ix3=floor(xg.lx(3)/2);
nsscale=zeros(size(dat.ns));
for isp=1:lsp
  nprof = dat.ns(:,ix2,ix3,isp);
  nsscale(:,:,:,isp) = repmat(nprof,[1 xg.lx(2) xg.lx(3)]);
end %for

%% SCALE EQ PROFILES UP TO SENSIBLE BACKGROUND CONDITIONS
scalefact=2*2.75;
for isp=1:lsp-1
  nsscale(:,:,:,isp) = scalefact * nsscale(:,:,:,isp);
end %for
nsscale(:,:,:,lsp) = sum(nsscale(:,:,:,1:6),4);   %enforce quasineutrality

end % function init_profile

function nsperturb = perturb_density(xg, dat, nsscale, x1, x2, params)

% because this is derived from current density it is invariant with respect
% to frame of reference.

lsp = size(dat.ns,4);

nsperturb=zeros(size(dat.ns));
n1=zeros(size(dat.ns));
for isp=1:lsp
  for ix2=1:xg.lx(2)
    % 3D noise
    %amplitude=randn(xg.lx(1),1,xg.lx(3));    %AGWN, note this can make density go negative so error checking needed below
    %amplitude=0.01*amplitude;

    %2D noise
    amplitude=randn(1,1,xg.lx(3));
    % amplitude=smooth(amplitude,10);  % requires curve fitting toolbox
    amplitude = movmean(amplitude, 10);
    amplitude=repmat(amplitude,[xg.lx(1),1,1]);
    amplitude=0.01*amplitude;

%     % single resonant perturbation; makes it easier to judge growth
%     x3dist=x3(end)-x3(1);
%     nhar=2;
%     lnoise=x3dist/nhar;
%     knoise=2*pi/lnoise;
%     amplitude=0.01*sin(knoise.*x3);
%     amplitude=reshape(amplitude,[1,1,lx3]);
%     amplitude=repmat(amplitude,[xg.lx(1),1,1]);

    n1here=amplitude.*nsscale(:,ix2,:,isp);     %perturbation seeding instability
    n1(:,ix2,:,isp)=n1here;                     %save the perturbation for computing potential perturbation

    nsperturb(:,ix2,:,isp) = nsscale(:,ix2,:,isp) .* (params.vn-params.v0) ./ ...
                            (params.v0*tanh((x2(ix2)) / params.ell) + params.vn);     %background density
    nsperturb(:,ix2,:,isp) = nsperturb(:,ix2,:,isp)+n1here;                                  %perturbation
  end %for
end %for
nsperturb=max(nsperturb,1e4);                        %enforce a density floor (particularly need to pull out negative densities which can occur when noise is applied)
nsperturb(:,:,:,lsp)=sum(nsperturb(:,:,:,1:6),4);    %enforce quasineutrality
n1(:,:,:,lsp)=sum(n1(:,:,:,1:6),4); %#ok<NASGU>

%% Remove any residual E-region from the simulation

taper=1/2+1/2*tanh((x1-params.x1ref)/params.dx1);
for isp=1:lsp-1
  for ix3=1:xg.lx(3)
    for ix2=1:xg.lx(2)
      nsperturb(:,ix2,ix3,isp)=1e6+nsperturb(:,ix2,ix3,isp).*taper;
    end
  end
end
inds = x1 < 150e3;
nsperturb(inds,:,:,:)=1e3;
nsperturb(:,:,:,lsp)=sum(nsperturb(:,:,:,1:6),4);    %enforce quasineutrality

end % function perturb_density


function Phitop = potential_bg(x2, lx2, lx3, params)

vel3=zeros(lx2,lx3);
for ix3=1:lx3
    vel3(:,ix3) = params.v0*tanh(x2 ./ params.ell) - params.vn;
end
vel3=flipud(vel3);    % this is needed for consistentcy with equilibrium...  Not completely clear why
E2top = vel3 * params.B1val;     % this is -1* the electric field

% integrate field to get potential
DX2=diff(x2);
DX2=[DX2,DX2(end)];
DX2=repmat(DX2(:),[1,lx3]);
Phitop=cumsum(E2top.*DX2,1);

end % function potential_bg


function create_Efield(cfg, xg, params)

gemini3d.fileio.makedir(cfg.E0_dir)

%% CREATE ELECTRIC FIELD DATASET
E.llon=100;
E.llat=100;
% NOTE: cartesian-specific code
if xg.lx(2) == 1
  E.llon = 1;
elseif xg.lx(3) == 1
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
% mlonmean = mean(E.mlon);
% mlatmean = mean(E.mlat);


%% INTERPOLATE X2 COORDINATE ONTO PROPOSED MLON GRID
xgmlon=squeeze(xg.phi(1,:,1)*180/pi);
% xgmlat=squeeze(90-xg.theta(1,1,:)*180/pi);
x2i=interp1(xgmlon,xg.x2(3:xg.lx(2)+2),E.mlon,'linear','extrap');
% x3i=interp1(xgmlat,xg.x3(3:lx3+2),E.mlat,'linear','extrap');

%% SET UP TIME VARIABLES
E.times = cfg.times(1):seconds(cfg.dtE0):cfg.times(end);
Nt = length(E.times);
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
E.flagdirich = zeros(Nt, 1);    %in principle can have different boundary types for different time steps...
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
      vel3(:,ilat) = params.v0*tanh(x2i ./ params.ell) - params.vn;
  end
  vel3=flipud(vel3);

  %CONVERT TO ELECTRIC FIELD (actually -1* electric field...)
  E2slab= vel3*params.B1val;

  %INTEGRATE TO PRODUCE A POTENTIAL OVER GRID - then save the edge
  %boundary conditions
  DX2=diff(x2i);
  DX2=[DX2,DX2(end)]; %#ok<AGROW>
  DX2=repmat(DX2(:),[1,E.llat]);
  Phislab=cumsum(E2slab.*DX2,1);    %use a forward difference
  E.Vmaxx2ist(:,it)=squeeze(Phislab(E.llon,:));
  E.Vminx2ist(:,it)=squeeze(Phislab(1,:));
end

%% Write electric field data to file
gemini3d.write.Efield(E, cfg.E0_dir, cfg.file_format)

end % function create_Efield
