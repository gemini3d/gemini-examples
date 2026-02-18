function results

direc0 = '.';
try
    cfg = gemini3d.read.config(direc0);
    xg = gemini3d.grid.cartesian(cfg);
catch
    error('Clone github.com/gemini3d/mat_gemini and add to path.')
end 
x1 = xg.x1(3:end-2)/1e3;

Qps = [0.1, 1, 10, 100]; % mW/m^2
Eps = [500,2000,10000,50000]; % eV
flags = [2008,2010]; % Fang et al. (2008, 2010)
num_sims = length(Qps)*length(Eps)*length(flags);

i = 1;
ne = zeros(num_sims,length(x1)+3);
for Qp = Qps
    for Ep = Eps
        for flag = flags
            direc = fullfile(direc0, sprintf('fang%i_Qp=%.0e_Ep=%.0e',flag,Qp,Ep));
            h5fn = fullfile(direc,'20150201_36000.000000.h5');
            nsall = h5read(h5fn,'/nsall');
            ne(i,1:3) = [Qp,Ep,flag];
            ne(i,4:end) = log10(squeeze(nsall(:,1,round(xg.lx(3)/2),7)));
            i = i + 1;
        end
    end
end

%% plot results
close all
figure('PaperPosition',[0,0,10,10],'PaperUnits','inches')
tlo = tiledlayout(2,2,'TileSpacing','tight','Padding','tight');
title(tlo,'Electron density from unaccel. Maxwellian spectra using Fang et al. (2008) vs. (2010) methods')
colors = [[0,0,1];[0,1,0];[1,0.5,0];[1,0,0]];

for i = 1:4
    nexttile
    title(sprintf('Q = %.1f mW/m^2',ne((i-1)*8+1,1)))
    hold on
    for j = 1:2:8
        plot(ne(j+8*(i-1),4:end),x1,'Color',colors(i,:)*j/8 ...
            ,'DisplayName',sprintf('%.1f keV, %i',ne(j,2)/1e3,ne(j,3)))
    end
    for j = 2:2:8
        plot(ne(j+8*(i-1),4:end),x1,'--','Color',colors(i,:)*(j-1)/8 ...
            ,'DisplayName',sprintf('%.1f keV, %i',ne(j,2)/1e3,ne(j,3)))
    end
    if i > 2
        xlabel('log_{10} Electron density (m^{-3})')
    end
    if mod(i,2) == 1
        ylabel('Altitude (km)')
    end
    xlim([9.25,1.03*max(ne(1:8+(i-1)*8,4:end),[],'all')])
    ylim([80,500])
    legend('Location','northeast','FontSize',11,'Color','None')
    grid on
end

saveas(gcf,fullfile(direc0,'fang2008_v_2010_ne.png'))
close all

%% plot result errors
fprintf('\n Ep \\ Qp\t')
for Qp = Qps; fprintf(['|',pad(sprintf('%.1f mW/m^2',Qp),23,'both')]); end
fprintf('\n         \t')
for i=1:4; fprintf('|   min    max  med-abs\t'); end
fprintf(['\n',pad('',106,'-'),'\n'])

close all
figure('PaperPosition',[0,0,10,10],'PaperUnits','inches')
tlo = tiledlayout(2,2,'TileSpacing','tight','Padding','tight');
title(tlo,'Electron density error from unaccel. Maxwellian spectra using Fang et al. (2008) vs. (2010) methods')
colors = [[0,0,1];[0,1,0];[1,0.5,0];[1,0,0]];

for j = 1:4
    fprintf('%4.1f keV',ne(2*j+8*(i-1),2)/1e3)
    nexttile
    title(sprintf('Q = %.1f keV',ne(2*j+8*(i-1),2)/1e3))
    hold on
    for i = 1:4
        ne2008 = ne(2*j-1 + 8*(i-1),4:end);
        ne2010 = ne(2*j   + 8*(i-1),4:end);
        ne_err = 100*(ne2010-ne2008)./ne2010;
        fprintf('\t| %5.1f%% %5.1f%% %5.1f%%',min(ne_err),max(ne_err),median(abs(ne_err)))
        plot(ne_err,x1,'Color',colors(i,:),'DisplayName',sprintf('%.1f mW/m^2',ne((i-1)*8+1,1)))
    end
    fprintf('\n')
    if j > 2
        xlabel('Error [log_{10} Electron density] (%)')
    end
    if mod(j,2) == 1
        ylabel('Altitude (km)')
    end
    ylim([80,500])
    legend('Location','best','FontSize',11,'Color','None')
    grid on
end

saveas(gcf,fullfile(direc0,'fang2008_v_2010_err.png'))
close all

end