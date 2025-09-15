function E = fac_said(E, Nt, gridflag, flagdip)
    % Function for 3D simulations, calculates FAC up/down 0.5 degree FWHM
    % Inputs:
    % E - Structure or Dataset (similar to xarray.Dataset)
    % gridflag - integer (used to determine direction)
    % flagdip - boolean flag
    
    % Check if E.mlon or E.mlat has only one value (similar to xarray dimension checks)
    % if length(E.mlon) == 1 || length(E.mlat) == 1
    %     error('This function is for 3D simulations only.');
    % end

    % Uniform in longitude
    shapelon = 1;

    config = "one-sided";
    % Calculate shape in latitude (similar to NumPy operations)
    if config == "one-sided"
    shapelat = exp(-( (E.mlat - E.mlatmean - 1.5 * E.mlatsig).^2 ) / (2 * E.mlatsig^2)) ...
              - exp(-( (E.mlat - E.mlatmean + 1.5 * E.mlatsig).^2 ) / (2 * E.mlatsig^2));
    elseif config == "two-sided"
    shapelat = 1/2*exp(-( (E.mlat - E.mlatmean - 1.5 * E.mlatsig).^2 ) / (2 * E.mlatsig^2)) ...
              - exp(-( (E.mlat - E.mlatmean + 1.5 * E.mlatsig).^2 ) / (2 * E.mlatsig^2))...
              + 1/2*exp(-( (E.mlat - E.mlatmean + 4.5 * E.mlatsig).^2 ) / (2 * E.mlatsig^2));
    end
              

    % Loop over times in E.time, starting from the 3rd element (MATLAB indices start at 1)
    for t_idx = 3:length(E.times)
        t = E.times(t_idx);
        
        % Set flagdiriich to zero
        E.flagdirich(t_idx) = 2;
        
        % Set key based on gridflag value
        if gridflag == 1
            k = 'Vminx1it';
        else
            k = 'Vmaxx1it';
        end

        % Update E.(k) based on the calculations
        E.(k)(:,:,t_idx) = E.Jtarg * shapelon * shapelat;
    end
end