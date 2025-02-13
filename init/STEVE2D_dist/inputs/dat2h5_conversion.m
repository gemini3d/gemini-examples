close all;clear all;clc;

filename_dat = "initial_conditions.dat";
fileID = fopen(filename_dat,'r');

data = fread(fileID,'double');
fclose(fileID);

filename_h5 = "initial_conditions.h5";
h5create(filename_h5,'/dataset1',size(data));
h5write(filename_h5,'/dataset1',data);
