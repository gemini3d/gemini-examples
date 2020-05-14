function Efield(cfg, xg)

narginchk(2, 2)
validateattributes(cfg, {'struct'}, {'scalar'}, mfilename, 'sim parameters', 1)
validateattributes(xg, {'struct'}, {'scalar'})

dir_out = absolute_path(cfg.E0_dir);
makedir(dir_out);

lx1 = xg.lx(1);
lx2 = xg.lx(2);
lx3 = xg.lx(3);

%% CREATE ELECTRIC FIELD DATASET
E.llon=100;
E.llat=100;
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
mlonmean = mean(E.mlon);
mlatmean = mean(E.mlat);

%INTERPOLATE X2 COORDINATE ONTO PROPOSED MLON GRID
% xgmlon=squeeze(xg.phi(1,:,1)*180/pi);
% x2=interp1(xgmlon,xg.x2(3:lx2+2),mlon,'linear','extrap');

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

%% SAVE THESE DATA TO APPROPRIATE FILES
% LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
% FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.
% THE EFIELD DATA DO NOT TYPICALLY NEED TO BE SMOOTHED.

write_Efield(cfg, E, dir_out)

end % function
