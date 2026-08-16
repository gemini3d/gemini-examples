import subprocess
import sys
import time

try:
    bin_name = sys.argv[1]
except:
    print('Please provide the path to gemini.bin')
    exit()

str_len = 108
Eps = ["5e+02","2e+03","1e+04","5e+04"]
Qps = ["1e-01","1e+00","1e+01","1e+02"]
flags = ["2008","2010"]

start0 = time.time()
id = 1
dur_avg = 0
for Ep in Eps:
    for Qp in Qps:
        for flag in flags:
            start1 = time.time()
            dur_old = dur_avg
            sim_name = "fang{}_Qp={}_Ep={}".format(flag,Qp,Ep)
            print('\n' + ''.center(str_len,'#'))
            print(' Name: {} '.format(sim_name).center(str_len,'#'))
            print(' ID: {} / 32 '.format(id).center(str_len,'#'))
            print(''.center(str_len,'#') + '\n')
            subprocess.run([bin_name,sim_name])
            dur_new = time.time() - start1
            if id != 1:
                dur_avg = (dur_old*(id-1) + dur_new) / id
            else:
                dur_avg = dur_new
            rem = (32-id)*dur_avg
            print('\n' + ''.center(str_len,'#'))
            print(' Current: {:.3f} seconds '.format(dur_new).center(str_len,'#'))
            print(' Average: {:.3f} seconds '.format(dur_avg).center(str_len,'#'))
            print(' Remaining: {:.3f} seconds '.format(rem).center(str_len,'#'))
            print(''.center(str_len,'#') + '\n\n' + ''.center(str_len,'-'))
            id += 1

print('\n' + ''.center(str_len,'#'))
print(' Time elapsed: {:.3f} seconds '.format(time.time()-start0).center(str_len,'#'))
print(''.center(str_len,'#') + '\n')