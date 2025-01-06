function [z, ne] = neprofile(filename)
    % Constants
    eps0 = 8.854e-12; % Permittivity of free space (F/m)
    me = 9.1e-31;     % Mass of an electron (kg)
    elchrg = 1.6e-19; % Elementary charge (C)

    % Helper function to convert plasma frequency to electron density
    function ne = fp2ne(fp)
        ne = (2 * pi * fp).^2 * eps0 * me / elchrg^2;
    end

    % Open the file
    fid = fopen(filename, 'r');
    if fid == -1
        error('Error opening the file: %s', filename);
    end

    % Skip the header lines
    for i = 1:7
        fgetl(fid);
    end

    % Initialize arrays
    z = [];
    fp = [];

    % Read data
    while ~feof(fid)
        line = fgetl(fid);
        if isempty(line)
            break;
        end
        z = [z; str2double(line(1:4)) * 1000]; % Convert km to m
        fp = [fp; str2double(line(5:end)) * 1e6]; % Convert MHz to Hz
    end

    % Close the file
    fclose(fid);

    % Convert to plasma density
    ne = fp2ne(fp);
end

