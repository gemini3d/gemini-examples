function efield(cfg, xg)
% this is possibly identical to mat_gemini/matlab/setup/Efield_BCs.m

narginchk(2, 2)
validateattributes(cfg, {'struct'}, {'scalar'}, mfilename, 'sim parameters', 1)
validateattributes(xg, {'struct'}, {'scalar'})

stdlib.fileio.makedir(cfg.E0_dir);

% lx1 = xg.lx(1);
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
% mlonmean = mean(E.mlon);
% mlatmean = mean(E.mlat);


%% INTERPOLATE X2 COORDINATE ONTO PROPOSED MLON GRID
xgmlon=squeeze(xg.phi(1,:,1)*180/pi);
x2=interp1(xgmlon,xg.x2(3:lx2+2),E.mlon,'linear','extrap');


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

densfact=3;
v0=-500e0;
ell=1e3;

vn=-v0*(densfact+1)./(densfact-1);
B1val=-50000e-9;
for it=1:Nt
    %ZEROS TOP CURRENT AND X3 BOUNDARIES DON'T MATTER SINCE PERIODIC



    %COMPUTE KHI DRIFT FROM APPLIED POTENTIAL
    vel3=zeros(E.llon, E.llat);
    for ilat=1:E.llat
        vel3(:,ilat)=v0*tanh(x2./ell)-vn;
    end


    %CONVERT TO ELECTRIC FIELD (actually minus electric field...)
    E2slab=vel3*B1val;


    %INTEGRATE TO PRODUCE A POTENTIAL OVER GRID - then save the edge
    %boundary conditions
    DX2=diff(x2,1);
    DX2=[DX2,DX2(end)];
    DX2=repmat(DX2(:),[1,E.llat]);
    Phislab=cumsum(E2slab.*DX2,1);    %use a forward difference
    E.Vmaxx2ist(:,it)=squeeze(Phislab(E.llon,:));
    E.Vminx2ist(:,it)=squeeze(Phislab(1,:));
end
%% SAVE THESE DATA TO APPROPRIATE FILES
% LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
% FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.
% THE EFIELD DATA DO NOT TYPICALLY NEED TO BE SMOOTHED.

gemini3d.write.Efield(E, cfg.E0_dir, cfg.file_format)

end % function
