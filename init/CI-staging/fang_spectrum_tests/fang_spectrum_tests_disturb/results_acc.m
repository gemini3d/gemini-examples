% For the accelerated simulations we need to compare against some reference
%   data to ensure it is working properly.  

direc_test='/Users/zettergm/simulations/ssd_ext/spectrumtest/spectrum_disturb/';
direc_ref='/Users/zettergm/simulations/ssd_ext/spectrumtest/spectrum_disturb_ref/';

% parameters over which simulations were run
Qps = [0.1, 1, 10, 100]; % mW/m^2
Eps = [500,2000,10000,50000]; % eV
flags = ["acc"]; % Fang et al. (2008, 2010)

num_sims = length(Qps)*length(Eps)*length(flags);

i = 1;
%ne = zeros(num_sims,length(x1)+3);
for Qp = Qps
    for Ep = Eps
        for flag = flags
            direc0 = fullfile(direc_test, sprintf('fang%s_Qp=%.0e_Ep=%.0e',flag,Qp,Ep));
            direc1 = fullfile(direc_ref, sprintf('fang%s_Qp=%.0e_Ep=%.0e',flag,Qp,Ep));
            gemini3d.compare(direc0,direc1);

            % h5fn = fullfile(direc,'20150201_36000.000000.h5');
            % nsall = h5read(h5fn,'/nsall');
            % ne(i,1:3) = [Qp,Ep,flag];
            % ne(i,4:end) = log10(squeeze(nsall(:,1,round(xg.lx(3)/2),7)));
            % i = i + 1;
        end
    end
end