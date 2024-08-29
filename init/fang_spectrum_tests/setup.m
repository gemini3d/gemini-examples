function setup

% NOTE: This program assumes you are running in an environment with standard
% POSIX permissions OR, if you are on an NFS filesystem, that you have
% inheritance bits properly set in your ACL. If you are on a shared system, you
% may need to contact your system administrator for help. For more information
% on NFS4 ACL's see https://www.osc.edu/book/export/html/4523 (J. Griffin,
% 8/9/2024)

direc = '.';
direc_eq = fullfile('..','fang2008_v_fang2010_eq');
try
    cfg = gemini3d.read.config(direc);
    xg = gemini3d.grid.cartesian(cfg);
catch
    error('Please clone github.com/gemini3d/mat_gemini and add it to your path.')
end 

Qps = [0.1, 1, 10, 100]; % mW/m^2
Eps = [500,2000,10000,50000]; % eV
flags = [2008,2010]; % Fang et al. (2008, 2010)

%% prepare inputs
ymd = cfg.ymd;
UTsec0 = cfg.UTsec0;
tdur = cfg.tdur;
dtprec = cfg.dtprec;
dtE0 = cfg.dtE0;
itprec = 0:dtprec:tdur;
itE0 = 0:dtE0:tdur;
ltprec = length(itprec);
ltE0 = length(itE0);

mlon = squeeze(xg.phi(end,:,1))*180/pi;
mlat = 90-squeeze(xg.theta(end,1,:))*180/pi;
llon = length(mlon);
llat = length(mlat);

pg.mlon = mlon;
pg.mlat = mlat;
pg.llon = llon;
pg.llat = llat;
pg.times = datetime(ymd) + seconds(UTsec0+itprec);

E.flagdirich = zeros(1,ltE0);
E.Exit = zeros(llon,llat,ltE0);
E.Eyit = zeros(llon,llat,ltE0);
E.Vminx1it = zeros(llon,llat,ltE0);
E.Vmaxx1it = zeros(llon,llat,ltE0);
E.Vminx2ist = zeros(llat,ltE0);
E.Vmaxx2ist = zeros(llat,ltE0);
E.Vminx3ist = zeros(llon,ltE0);
E.Vmaxx3ist = zeros(llon,ltE0);
E.mlon = mlon;
E.mlat = mlat;
E.llon = llon;
E.llat = llat;
E.times = datetime(ymd) + seconds(UTsec0+itE0);

%% copy files
for Qp = Qps
    for Ep = Eps
        for flag = flags
            direc_sim = fullfile(direc, sprintf('fang%i_Qp=%.0e_Ep=%.0e',flag,Qp,Ep));
            if isfolder(direc_sim)
                fprintf('Skipped %s\n',direc_sim)
                continue
            end
            cfg_fn = sprintf('config%i.nml',flag);
            mkdir(direc_sim)
            mkdir(fullfile(direc_sim,'inputs'))
            copyfile(fullfile(direc,cfg_fn), ...
                fullfile(direc_sim,'config.nml'),'f')
            copyfile(fullfile(direc,cfg_fn), ...
                fullfile(direc_sim,'inputs','config.nml'),'f')
            copyfile(fullfile(direc,direc_eq,'20150201_35850.000000.h5'), ...
                fullfile(direc_sim,'inputs','initial_conditions.h5'),'f')
            copyfile(fullfile(direc,direc_eq,'inputs','simgrid.h5'), ...
                fullfile(direc_sim,'inputs','simgrid.h5'),'f')
            copyfile(fullfile(direc,direc_eq,'inputs','simsize.h5'), ...
                fullfile(direc_sim,'inputs','simsize.h5'),'f')
            pg.Qit = ones(llon,llat,ltprec)*Qp;
            pg.E0it = ones(llon,llat,ltprec)*Ep;
            gemini3d.write.precip(pg,fullfile(direc_sim,'inputs','particles'))
            gemini3d.write.Efield(E,fullfile(direc_sim,'inputs','fields'));
        end
    end
end
end
