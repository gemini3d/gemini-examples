function [z, ne] = neprofile(filename)
    % read netCDF files from RO data

    lat = ncread(filename,'GEO_lat');
    lon = ncread(filename,'GEO_lon');
    z = ncread(filename,'MSL_alt');  % in km
    ne = ncread(filename,'ELEC_dens'); %el/cm^3
    
    min_alt = 50; %consider data above 50 km
    differences = abs(z - min_alt);
    [~, index_min_alt] = min(differences);
    z = z(index_min_alt:end);
    ne = ne(index_min_alt:end);
    z = z.*10^(3); % alt in meters
    ne = ne.*10^(6); % /m^3
end

