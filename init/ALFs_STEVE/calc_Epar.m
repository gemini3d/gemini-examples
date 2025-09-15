% Set the GEMINI_ROOT path
setenv('GEMINI_ROOT', '/Users/vaggu/Work/gemini3d/build/msis/');

% Read simulation data
iframe = 21;
direc = '/Users/vaggu/Work/GEMINI_projects/ALFs_STEVE/Non-linear-currents/';
cfg = gemini3d.read.config(direc);
xg = gemini3d.read.grid(direc);
dat = gemini3d.read.frame(direc,"time",cfg.times(iframe));  % Use frame 16
y = xg.x3(3:end-2);
z = xg.x1(3:end-2);

% Recompute conductivities over grid
[sigP, sigH, sig0, SigP, SigH, incap, Incap] = ...
    gemini3d.gemscr.postprocess.conductivity_reconstruct(cfg.times(iframe), dat, cfg, xg);

% Have J1, can compute sigma0, so can get E1
Jz = dat.J1;  % Field-aligned current, positive up
sig0 = permute(sig0,[1 3 2]);
sigH = permute(sigH,[1 3 2]);
sigP = permute(sigP,[1 3 2]);
Ez = Jz ./ sig0;

% compute E_perp in E-W and N-S
%using conductivity tensor
% Inputs (array-sized): J2 (E–W), J3 (N–S), sigP, sigH
dnm = sigP.^2 + sigH.^2 ;
E2  = (-sigH .* dat.J3 + sigP .* dat.J2) ./ dnm;   % E–W electric field
E3  = ( sigP .* dat.J3 + sigH .* dat.J2) ./ dnm;   % N–S electric field

%% plot E, sigma, and J (both perp and par)
figure('Units', 'Inches', 'Position', [0, 0, 16, 16], 'PaperPositionMode', 'auto');

%electric fields
subplot(431)
Ezplot = reshape(Ez, [length(z), length(y)]);
pcolor(y./1e3, z./1e3, Ezplot);
shading interp;
% xlabel('northward dist. [km]');
ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$E_\parallel$ [V/m]', 'Interpreter', 'latex');
% grid on;
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

subplot(432)
Ezplot = reshape(E2, [length(z), length(y)]);
pcolor(y./1e3, z./1e3, Ezplot);
shading interp;
% xlabel('northward dist. [km]');
% ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$E_\perp$ (E-W) [V/m]', 'Interpreter', 'latex');
% grid on;
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

subplot(433)
Ezplot = reshape(E3, [length(z), length(y)]);
pcolor(y./1e3, z./1e3, Ezplot);
shading interp;
% xlabel('northward dist. [km]');
% ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$E_\perp$ (N-S) [V/m]', 'Interpreter', 'latex');
% grid on;
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

%currents
subplot(434)
J1plot = reshape(dat.J1, [length(z), length(y)]);
pcolor(y./1e3, z./1e3, J1plot);
shading interp;
% xlabel('northward dist. [km]');
ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$J_\parallel$ [A/m$^2$]', 'Interpreter', 'latex');
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

subplot(435)
J2plot = reshape(dat.J2, [length(z), length(y)]);
pcolor(y./1e3, z./1e3, J2plot);
shading interp;
% xlabel('northward dist. [km]');
% ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$J_\perp$ (E-W) [A/m$^2$]', 'Interpreter', 'latex');
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

subplot(436)
J3plot = reshape(dat.J3, [length(z), length(y)]);
pcolor(y./1e3, z./1e3, J3plot);
shading interp;
% xlabel('northward dist. [km]');
% ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$J_\perp$ (N-S) [A/m$^2$]', 'Interpreter', 'latex');
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

%conductivities
subplot(437)
sig0plot = reshape(sig0, [length(z), length(y)]);
pcolor(y./1e3, z./1e3, sig0plot);
shading interp;
% xlabel('northward dist. [km]');
ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$Sig0_\parallel$ [S/m]', 'Interpreter', 'latex');
% grid on;
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

subplot(438)
sigHplot = reshape(sigH, [length(z), length(y)]);
pcolor(y./1e3, z./1e3, sigHplot);
shading interp;
% xlabel('northward dist. [km]');
% ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$SigH_\perp$ [S/m]', 'Interpreter', 'latex');
% grid on;
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

subplot(439)
sigPplot = reshape(sigP, [length(z), length(y)]);
pcolor(y./1e3, z./1e3, sigPplot);
shading interp;
% xlabel('northward dist. [km]');
% ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$SigP_\perp$ [S/m]', 'Interpreter', 'latex');
% grid on;
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

%ion-electron mobilities
subplot(4,3,10)
v1plot = reshape(dat.v1, [length(z), length(y)]);
pcolor(y./1e3, z./1e3, v1plot);
shading interp;
xlabel('northward dist. [km]');
ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$v_\parallel$ [m/s]', 'Interpreter', 'latex');
% grid on;
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

subplot(4,3,11)
pcolor(y./1e3, z./1e3, dat.v2);
shading interp;
xlabel('northward dist. [km]');
% ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$v_\perp$ (E-W) [m/s]', 'Interpreter', 'latex');
% grid on;
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;

subplot(4,3,12)
pcolor(y./1e3, z./1e3, dat.v3);
shading interp;
xlabel('northward dist. [km]');
% ylabel('altitude [km]');
ylim([80, 500]);
xlim([-7, 5]);
colorbar;
title('$v_\perp$ (N-S) [m/s]', 'Interpreter', 'latex');
% grid on;
ax = gca;
% ax.GridLineStyle = ':';
% ax.GridColor = 'k';
% ax.GridAlpha = 0.5;
% ax.LineWidth = 1.2;
ax.FontSize = 14;
p0 = 'E_J_V_sigma.png';
fullpath = fullfile(direc,p0);
saveas(gcf, fullpath);