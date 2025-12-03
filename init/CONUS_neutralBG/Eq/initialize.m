run ~/Projects/mat_gemini/setup;

%% Initialized MSIS/HWM-14

initialtimeDT = datetime([2022,12,19,0,0,0]); % initial time
dtneu = 900; % timestep (sec)

ymd0=[year(initialtimeDT),month(initialtimeDT),day(initialtimeDT)];
%UTsec0=initialtime(6);
UTsec0=3600*hour(initialtimeDT) + 60*minute(initialtimeDT) + second(initialtimeDT);
system(['mkdir dataneut']);

ymd=ymd0;
UTsec=UTsec0;
freal = 'single';

%% Create data files
for ii=0:1:96 % save for a day

    currenttimeDT = initialtimeDT + ii*seconds(dtneu);

    % Prepare background fields
    out = prepareGEMINIbkgd(year(currenttimeDT),month(currenttimeDT),day(currenttimeDT),hour(currenttimeDT),minute(currenttimeDT));

    % Write data to file
    timevar=datetime([ymd,0,0,UTsec]);
    filenamez=gemini3d.datelab(timevar);
    filename=strcat('dataneut/',filenamez,'.h5');

    stdlib.h5save(filename, '/n0all', out.O, "type",  freal)               % O density
    stdlib.h5save(filename, '/nN2all', out.N2, "type",  freal)             % N2 density
    stdlib.h5save(filename, '/nO2all', out.O2, "type",  freal)             % O2 density
    stdlib.h5save(filename, '/nNall', out.N, "type",  freal)               % N density
    stdlib.h5save(filename, '/nHall', out.H, "type",  freal)               % H density
    stdlib.h5save(filename, '/vnxall', out.u_zonal, "type",  freal)        % zonal wind
    stdlib.h5save(filename, '/vnrhoall', out.v_meridional, "type",  freal) % meridional wind
    stdlib.h5save(filename, '/Tnall', out.temperature, "type",  freal)     % temperature

    %Increment time
    [ymd,UTsec]=gemini3d.dateinc(dtneu,ymd,UTsec);
end

% simsize.h5 is similar to the one we have for neutral perturbations and includes
% numbers of points in each direction (altitude, longitude, latitude)
filename=['dataneut/','simsize.h5'];
disp("write " + filename)
if isfile(filename), delete(filename), end
stdlib.h5save(filename, '/lx1', size(out.O,1), "type", "int32")
stdlib.h5save(filename, '/lx2', size(out.O,2), "type", "int32")
stdlib.h5save(filename, '/lx3', size(out.O,3), "type", "int32")

% gridneut.h5 includes coordinates (alt, lon, lat)
stdlib.h5save('dataneut/simgrid.h5', '/alt', out.alt3d.*1000, "type",  freal)
stdlib.h5save('dataneut/simgrid.h5', '/glat', out.lat3d, "type",  freal)
stdlib.h5save('dataneut/simgrid.h5', '/glon', out.lon3d, "type",  freal)

