function Efield_BCs(p, xg)
arguments
  p (1,1) struct
  xg (1,1) struct
end

% Set input potential/FAC boundary conditions and write these to a set of
% files that can be used an input to GEMINI.  This ia a basic examples that
% can make Gaussian shaped potential or FAC inputs using an input width.

dir_out = p.E0_dir;
%stdlib.fileio.makedir(dir_out);

lx1 = xg.lx(1);
lx2 = xg.lx(2);
lx3 = xg.lx(3);

%% CREATE ELECTRIC FIELD DATASET
E.llon=1024;
E.llat=1024;
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
E.mlonmean = mean(E.mlon);
E.mlatmean = mean(E.mlat);

%% WIDTH OF THE DISTURBANCE
if isfield(p, 'Efield_latwidth')
  [E.mlatsig, E.sigx3] = Esigma(p.Efield_latwidth, mlatmax, mlatmin, xg.x3);
end
if isfield(p, 'Efield_lonwidth')
   [E.mlonsig, E.sigx2] = Esigma(p.Efield_lonwidth, mlonmax, mlonmin, xg.x2);
end
if isfield(p, 'Efield_fracwidth')
  warning('Efield_fracwidth is deprecated. Please use Efield_lonwidth or Efield_latwidth')
  if E.llat ~= 1
    [E.mlatsig, E.sigx3] = Esigma(p.Efield_fracwidth, mlatmax, mlatmin, xg.x3);
  end
  if E.llon ~= 1
    [E.mlonsig, E.sigx2] = Esigma(p.Efield_fracwidth, mlonmax, mlonmin, xg.x2);
  end
end
%% TIME VARIABLE (SECONDS FROM SIMULATION BEGINNING)
E.times = p.times(1):seconds(p.dtE0):p.times(end);
Nt = length(E.times);
%% CREATE DATA FOR BACKGROUND ELECTRIC FIELDS
if isfield(p, 'Exit')
  E.Exit = p.Exit * ones(E.llon, E.llat, Nt);
else
  E.Exit = zeros(E.llon, E.llat, Nt);
end
if isfield(p, 'Eyit')
  E.Eyit = p.Eyit * ones(E.llon, E.llat, Nt);
else
  E.Eyit = zeros(E.llon, E.llat, Nt);
end

%% CREATE DATA FOR BOUNDARY CONDITIONS FOR POTENTIAL SOLUTION
% if 0 data is interpreted as FAC, else we interpret it as potential
E.flagdirich=zeros(Nt,1);    %in principle can have different boundary types for different time steps...
E.Vminx1it = zeros(E.llon,E.llat, Nt);
E.Vmaxx1it = zeros(E.llon,E.llat, Nt);
%these are just slices
E.Vminx2ist = zeros(E.llat, Nt);
E.Vmaxx2ist = zeros(E.llat, Nt);
E.Vminx3ist = zeros(E.llon, Nt);
E.Vmaxx3ist = zeros(E.llon, Nt);

%% synthesize feature
if isfield(p, 'Etarg')
  E.Etarg = p.Etarg;
  E = Efield_target(E, xg, lx1, lx2, lx3, Nt);
elseif isfield(p, 'Jtarg')
  E.Jtarg = p.Jtarg;
  E = Jcurrent_target(E, Nt);
end

%% SAVE THESE DATA TO APPROPRIATE FILES
% LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
% FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.
% THE EFIELD DATA DO NOT TYPICALLY NEED TO BE SMOOTHED.

%gemini3d.write.Efield(E, dir_out, p.file_format)
gemini3d.write.Efield(E, dir_out)

end % function


function E = Jcurrent_target(E, Nt)

% Set the top boundary shape (current density) and potential solve type
% flag.  Can be adjusted by user to achieve any desired shape.

Jpk=E.Jtarg;
%mlonsig=E.Efield_lonwidth;
%mlatsig=E.Efield_latwidth;
displace=10*E.mlatsig;
mlatctr=E.mlatmean+displace*tanh((E.MLON-E.mlonmean)/(2*E.mlonsig));    %changed so the arc is wider compared to its twisting
for it=1:Nt
    E.flagdirich(it)=0;
    E.Vminx1it(:,:,it)=zeros(E.llon,E.llat);
    if (it>2)
      E.Vmaxx1it(:,:,it)=Jpk.*exp(-(E.MLON-E.mlonmean).^2/2/E.mlonsig^2).*exp(-(E.MLAT-mlatctr-1.5*E.mlatsig).^2/2/E.mlatsig^2);
      E.Vmaxx1it(:,:,it)=E.Vmaxx1it(:,:,it)-Jpk.*exp(-(E.MLON-E.mlonmean).^2/2/E.mlonsig^2).*exp(-(E.MLAT-mlatctr+1.5*E.mlatsig).^2/2/E.mlatsig^2);
    else
      E.Vmaxx1it(:,:,it)=zeros(E.llon,E.llat);
    end %if
end %for

end % function


function E = Efield_target(E, xg, lx1, lx2, lx3, Nt)

% Set the top boundary shape (potential) and potential solve type flag

%% create feature defined by Efield
if lx3 == 1 % east-west
  S = E.Etarg * E.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
  taper = erf((E.MLON - E.mlonmean) / E.mlonsig);
elseif lx2 == 1 % north-south
  S = E.Etarg * E.sigx3 .* xg.h3(lx1, 1, floor(lx3/2)) .* sqrt(pi)./2;
  taper = erf((E.MLAT - E.mlatmean) / E.mlatsig);
else % 3D
  S = E.Etarg * E.sigx2 .* xg.h2(lx1, floor(lx2/2), 1) .* sqrt(pi)./2;
  taper = erf((E.MLON - E.mlonmean) / E.mlonsig) .* erf((E.MLAT - E.mlatmean) / E.mlatsig);
end

% x2ctr = 1/2*(xg.x2(lx2) + xg.x2(1));
for i = 1:Nt
  E.flagdirich(i)=1;
  E.Vmaxx1it(:,:,i) = S .* taper;
end

end % function


function [wsig, xsig] = Esigma(pwidth, pmax, pmin, px)

% Set width given a fraction of the coordinate an extent

wsig = pwidth * (pmax - pmin);
xsig = pwidth * (max(px) - min(px));

end % function
