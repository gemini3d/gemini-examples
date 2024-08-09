function run(gemini_bin)
arguments
    gemini_bin (1,1) string {mustBeFile}
end

direc0 = '.';
str_len = 108;
hash_bar = [pad('',str_len,'both','#'),'\n'];

% Eps = ["5e+02","2e+03","1e+04","5e+04"];
% Qps = ["1e-01","1e+00","1e+01","1e+02"];
% flags = ["2008","2010"];
Qps = [0.1, 1, 10, 100]; % mW/m^2
Eps = [500,2000,10000,50000]; % eV
flags = [2008,2010]; % Fang et al. (2008, 2010)
num_sims = length(Qps)*length(Eps)*length(flags);

start0 = datetime;
id = 1;
dur_avg = 0;
for Ep = Eps
    for Qp = Qps
        for flag = flags
            start1 = datetime;
            dur_old = dur_avg;
            % sim_name = sprintf('fang%s_Qp=%s_Ep=%s',flag,Qp,Ep);
            sim_name = sprintf('fang%i_Qp=%.0e_Ep=%.0e',flag,Qp,Ep);

            fprintf(['\n',hash_bar])
            fprintf([pad(sprintf(' Name: %s ',sim_name),str_len,'both','#'),'\n'])
            fprintf([pad(sprintf(' ID: %i / %i ',id,num_sims),str_len,'both','#'),'\n'])
            fprintf([hash_bar,'\n'])

            command = sprintf('%s %s',gemini_bin,fullfile(direc0,sim_name));
            system(command);

            dur_new = seconds(datetime - start1);
            if id ~= 1
                dur_avg = (dur_old*(id-1)+dur_new) / id;
            else
                dur_avg = dur_new;
            end
            dur_rem = (num_sims - id)*dur_avg;

            fprintf(['\n',hash_bar])
            fprintf([pad(sprintf(' Current: %.3f seconds ',dur_new),str_len,'both','#'),'\n'])
            fprintf([pad(sprintf(' Average: %.3f seconds ',dur_avg),str_len,'both','#'),'\n'])
            fprintf([pad(sprintf(' Remaining: %.3f seconds ',dur_rem),str_len,'both','#'),'\n'])
            fprintf([hash_bar,'\n',pad('',str_len,'both','-'),'\n'])

            id = id + 1;
        end
    end
end

dur_tot = seconds(datetime - start0);

fprintf(['\n',hash_bar])
fprintf([pad(sprintf(' Time elapsed: %.3f seconds ',dur_tot),str_len,'both','#'),'\n'])
fprintf([hash_bar,'\n'])

end
