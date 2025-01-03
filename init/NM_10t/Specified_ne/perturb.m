function perturb(cfg, xg)
    % Constants
    filename = "fp_profile.txt";

    % Read the plasma profile
    [z, ne] = neprofile(filename);
    %ne = ne * 1.4;

    % Out-of-bounds altitude handling
    zmin = min(z);
    zmax = max(z);
    zgridmin = min(xg.alt(:));
    zgridmax = max(xg.alt(:));
    lsample=512;
    zdatasample = linspace(zgridmin, zgridmax, lsample);
    
    % Initialize sampled density
    nedatasample = zeros(size(zdatasample));
    i = 1;
    
    % Fill data for points below min altitude of data
    while zdatasample(i) < zmin
        nedatasample(i) = 1e-20;
        i = i + 1;
    end
    imin = i;

    % Interpolation for points within data bounds
    while i <= lsample && zdatasample(i) < zmax
        i = i + 1;
    end
    imax = i-1;
    nedatasample(imin:imax) = interp1(z, ne, zdatasample(imin:imax), 'linear', 'extrap');
    
    % Fill value for data above max altitude range
    for i = imax+1:lsample
        ne3 = nedatasample(i-3);
        ne2 = nedatasample(i-2);
        nedatasample(i) = nedatasample(i-1) * ne2 / ne3;
    end

    % Construct initial condition for density of all species
    x1 = xg.x1(3:end-2);
    x2 = xg.x2(3:end-2);
    x3 = xg.x3(3:end-2);
    nsperturb = zeros(7, length(x1), length(x2), length(x3));

    for i = 1:length(x2)
        for j = 1:length(x3)
            nsperturb(7, :, i, j) = interp1(zdatasample, nedatasample, squeeze(xg.alt(:, i, j)), 'linear', 'extrap');
        end
    end

    % Apply assumed composition
    comp = 0.5 + 0.5 * tanh((x1 - 200e3) / 15e3);
    for i = 1:length(x2)
        for j = 1:length(x3)
            nmolec = (1 - comp') .* nsperturb(7, :, i, j);
            natomic = comp' .* nsperturb(7, :, i, j);
            nsperturb(1, :, i, j) = 0.98 * natomic;
            nsperturb(5, :, i, j) = 0.01 * natomic;
            nsperturb(6, :, i, j) = 0.01 * natomic;
            nsperturb(2, :, i, j) = (1/3) * nmolec;
            nsperturb(3, :, i, j) = (1/3) * nmolec;
            nsperturb(4, :, i, j) = (1/3) * nmolec;
        end
    end

    % Enforce nonzero minimum density
    nsperturb = max(nsperturb, 1e4);
    nsperturb(7, :, :, :) = sum(nsperturb(1:5, :, :, :), 1);

    % Read frame data
    % dat = gemini3d.read.frame(cfg.indat_file, var=["ns", "Ts", "vs1"]);
    dat = gemini3d.read.frame(cfg.indat_file,"vars",["ns", "Ts", "v1"]);

    % Write the new state
    % gemini3d.write.state(cfg.indat_file,dat,"ns",nsperturb);
    gemini3d.write.state(cfg.indat_file, dat);
end
