function out = prepareGEMINIbkgd(year,month,dayUTC,hour,minute,alt_km)

if evalin('base','exist(''day'',''var'')')
    evalin('base','clear day');
end

if nargin < 6 || isempty(alt_km)
    alt_km = [70:20:500, 600:100:900];
end

lon = 0:1:359;
lat = -90:1:90;
Nlon = numel(lon);
Nlat = numel(lat);
Nalt = numel(alt_km);

[LonGrid, LatGrid] = meshgrid(lon, lat);  % Nlat x Nlon
latVec = LatGrid(:);
lonVec = LonGrid(:);
Npoints = numel(latVec);

% Allocate arrays (later permuted to [alt,lon,lat])
O2 = nan(Nlat,Nlon,Nalt);
O  = nan(Nlat,Nlon,Nalt);
N2 = nan(Nlat,Nlon,Nalt);
H  = nan(Nlat,Nlon,Nalt);
N  = nan(Nlat,Nlon,Nalt);
Tfield = nan(Nlat,Nlon,Nalt);
v_mer = nan(Nlat,Nlon,Nalt);
u_zon = nan(Nlat,Nlon,Nalt);

dt = datetime(year,month,dayUTC,hour,minute,0,'TimeZone','UTC');
doy = day(dt,'dayofyear');
secondsSinceMidnight = hour*3600 + minute*60;
alt_m = alt_km*1e3;

fprintf('Building %dx%dx%d grid (lat,lon,alt) ...\n',Nlat,Nlon,Nalt);

for k = 1:Nalt
    altm_k = alt_m(k);
    alt_vec = repmat(altm_k,Npoints,1);

    % MSIS fields
    [Ttmp, rho] = atmosnrlmsise00(alt_vec, latVec, lonVec, year, doy, secondsSinceMidnight);
    Tvals = Ttmp(:,2);
    O2_col = rho(:,4);
    O_col  = rho(:,2);
    N2_col = rho(:,3);
    H_col  = rho(:,7);
    N_col  = rho(:,8);

    O2(:,:,k) = reshape(O2_col,Nlat,Nlon);
    O(:,:,k)  = reshape(O_col,Nlat,Nlon);
    N2(:,:,k) = reshape(N2_col,Nlat,Nlon);
    H(:,:,k)  = reshape(H_col,Nlat,Nlon);
    N(:,:,k)  = reshape(N_col,Nlat,Nlon);
    Tfield(:,:,k) = reshape(Tvals,Nlat,Nlon);

    % Horizontal wind fields
    hwm_alt_m = min(altm_k,500e3);
    alt_hwm_vec = repmat(hwm_alt_m,Npoints,1);
    day_vec = repmat(double(doy),Npoints,1);
    sec_vec = repmat(double(secondsSinceMidnight),Npoints,1);
    wind = atmoshwm(latVec,lonVec,alt_hwm_vec,...
        'day',day_vec,'seconds',sec_vec,'model','total','version','14');
    v_mer(:,:,k) = reshape(wind(:,1),Nlat,Nlon);
    u_zon(:,:,k) = reshape(wind(:,2),Nlat,Nlon);

    if mod(k,5)==0 || k==Nalt
        fprintf('  done altitude %d/%d (%.1f km)\n',k,Nalt,alt_km(k));
    end
end

fprintf('Reordering to [alt, lon, lat] ...\n');

% Permute to [vertical,zonal,meridional] compatible with GEMINI
permOrder = [3,2,1];
O2 = permute(O2,permOrder);
O  = permute(O,permOrder);
N2 = permute(N2,permOrder);
H  = permute(H,permOrder);
N  = permute(N,permOrder);
Tfield = permute(Tfield,permOrder);
v_mer = permute(v_mer,permOrder);
u_zon = permute(u_zon,permOrder);
[lon3d,lat3d,alt3d] = ndgrid(lon,lat,alt_km);
lon3d = permute(lon3d,[3,1,2]);
lat3d = permute(lat3d,[3,1,2]);
alt3d = permute(alt3d,[3,1,2]);

% Put everyting in out variable
out.alt_km = alt_km(:);
out.lon = lon(:);
out.lat = lat(:);
out.alt3d = alt3d;
out.lon3d = lon3d;
out.lat3d = lat3d;

out.O2 = O2;
out.O  = O;
out.N2 = N2;
out.H  = H;
out.N  = N;
out.temperature = Tfield;
out.v_meridional = v_mer;
out.u_zonal = u_zon;

fprintf('Finished preparing MSIS+HWM fields.\n');

end
