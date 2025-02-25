function particles_BCs(p, xg)
% create particle precipitation
arguments
  p (1,1) struct
  xg (1,1) struct
end

outdir = p.prec_dir;
%stdlib.fileio.makedir(outdir)

%% CREATE PRECIPITATION CHARACTERISTICS data
% number of grid cells.
% This will be interpolated to grid, so 100x100 is arbitrary
precip = struct('llon', 1024, 'llat', 1024);

if xg.lx(2) == 1    % cartesian
  precip.llon=1;
elseif xg.lx(3) == 1
  precip.llat=1;
end

%% TIME VARIABLE (seconds FROM SIMULATION BEGINNING)
% dtprec is set in config.nml
precip.times = p.times(1):seconds(p.dtprec):p.times(end);
Nt = length(precip.times);

%% CREATE PRECIPITATION INPUT DATA
% Qit: energy flux [mW m^-2]
% E0it: characteristic energy [eV]
precip.Qit = zeros(precip.llon, precip.llat, Nt);
precip.E0it = zeros(precip.llon,precip.llat, Nt);

% did user specify on/off time? if not, assume always on.
if isfield(p, 'precip_startsec')
  i_on = round(p.precip_startsec / p.dtprec) + 1;
else
  i_on = 1;
end

if isfield(p, 'precip_endsec')
  i_off = round(min(p.tdur, p.precip_endsec) / p.dtprec);
else
  i_off = Nt;
end

if ~isfield(p, 'Qprecip')
  warning('You should specify "Qprecip, Qprecip_background, E0precip" in "setup" namelist of config.nml. Defaulting to Q=1, E0=1000')
  Qprecip = 1;
  Qprecip_bg = 0.01;
  E0precip = 1000;
else
  Qprecip = p.Qprecip;
  Qprecip_bg = p.Qprecip_background;
  E0precip = p.E0precip;
end

precip = gemini3d.particles.grid(xg, p);


%% User-defined precipitation shape
lt=Nt;
precip.Qit=zeros(precip.llon,precip.llat,lt);
precip.E0it=zeros(precip.llon,precip.llat,lt);

mlonsig=precip.mlon_sigma;
mlatsig=precip.mlat_sigma;

displace=10*mlatsig;
mlatctr=precip.mlat_mean+displace*tanh((precip.MLON-precip.mlon_mean)/(2*mlonsig));     %changed so the arc is wider compared to its twisting

Qpk=Qprecip;
E0pk=E0precip;
QBG=Qprecip_bg;
for it=1:lt
  shapefn=exp(-(precip.MLON-precip.mlon_mean).^2/2/mlonsig^2).*exp(-(precip.MLAT-mlatctr-1.5*mlatsig).^2/2/mlatsig^2);
  Qittmp=Qpk.*shapefn;
  precip.E0it(:,:,it)=E0pk;   %*ones(llon,llat);     %eV
  inds=find(Qittmp<QBG);        %define a background flux (enforces a floor for production rates)
  Qittmp(inds)=QBG;
  precip.Qit(:,:,it)=Qittmp;
end


%


%% Error checking
if any(~isfinite(precip.Qit)), error('particle_BCs:value_error', 'precipitation flux not finite'), end
if any(~isfinite(precip.E0it)), error('particle_BCs:value_error', 'E0 not finite'), end


%% CONVERT THE ENERGY TO EV
%E0it = max(E0it,0.100);
%E0it = E0it*1e3;

gemini3d.write.precip(precip, outdir)

end % function