%addpath ../../script_utils;

clear all
close all

%OUTPUT FILE LOCATION
% outdir='./Efield_outdir_rocket/';
outdir='Efield_outdir_clayton5_testclean3';
system(['mkdir ',outdir]);

%get time
%get data

%load('clayton5_step_smooth7.mat')

%load('Eclean_c5.mat')
load('Eclean_c5_128pts.mat')
clear outu outv
outu = permute(Exclean,[3,1,2]);
outv = permute(Eyclean,[3,1,2]);
clear Exclean Eyclean

outy = double(outy);
load('isinglass_clayton_grid.mat')

%READ IN FIELD AND POSITION DATA FROM AMISR HDF5 FILEA
datapath='./';
% Exgeog=cast(hdf5read([datapath,'20170302.002_lp_1min-cal_2dVEF_001001_NoLonely-geo.h5'],'Fit2D/Ex_geo'),'double');
% Eygeog=cast(hdf5read([datapath,'20170302.002_lp_1min-cal_2dVEF_001001_NoLonely-geo.h5'],'Fit2D/Ey_geo'),'double');
% Exgeomagdat=cast(hdf5read([datapath,'20170302.002_lp_1min-cal_2dVEF_001001_NoLonely-geo.h5'],'Fit2D/Ex'),'double');
% Eygeomagdat=cast(hdf5read([datapath,'20170302.002_lp_1min-cal_2dVEF_001001_NoLonely-geo.h5'],'Fit2D/Ey'),'double');
% Xgeo=cast(hdf5read([datapath,'20170302.002_lp_1min-cal_2dVEF_001001_NoLonely-geo.h5'],'Grid/X_geo'),'double');    % Geo lon
% Ygeo=cast(hdf5read([datapath,'20170302.002_lp_1min-cal_2dVEF_001001_NoLonely-geo.h5'],'Grid/Y_geo'),'double');    % Geo lat
% Exgeomagdat=zeros(length(Xgeo),length(Ygeo),length(vvelmapx(:,1,1)));
% Eygeomagdat=zeros(length(Xgeo),length(Ygeo),length(vvelmapx(:,1,1)));
% for i = 1:length(vvelmapx(:,1,1))
%     Fu = scatteredInterpolant(reshape(vvelmapx(i,:,:),[1510 1]),reshape(vvelmapy(i,:,:),[1510 1]),reshape(vvelmapu(i,:,:),[1510 1]));
%     Fv = scatteredInterpolant(reshape(vvelmapx(i,:,:),[1510 1]),reshape(vvelmapy(i,:,:),[1510 1]),reshape(vvelmapv(i,:,:),[1510 1]));
%     Exgeomagdat(:,:,i)=Fu(Xgeo,Ygeo);
%     Eygeomagdat(:,:,i)=Fv(Xgeo,Ygeo);
% end
    Exgeomagdat=outu;
    Eygeomagdat=outv;
% Xgeo=outx;    % Geo lon
% Ygeo=outy;    % Geo lat
% for i=1:1:length(outx(:,1,1))
% Xgeo(i,:,:)=squeeze(outx(i,:,:))';    % Geo lon
% Ygeo(i,:,:)=squeeze(outy(i,:,:))';    % Geo lat
% end
for i=1:1:length(outt)
Xgeo(i,:,:)=(squeeze(glon(100,1:2:end-1,1:2:end-1)))';    % Geo lon
Ygeo(i,:,:)=(squeeze(glat(100,1:2:end-1,1:2:end-1)))';    % Geo lat
end
[lt,llon,llat]=size(Exgeomagdat);
clear glon glat

% %GET THE DIMENSIONS PERMUTED CORRECTLY
% for it=1:lt
%    Xgeo_corr(:,:,it)=permute(squeeze(Xgeo(it,:,:)),[2,1]);
%    Ygeo_corr(:,:,it)=permute(squeeze(Ygeo(it,:,:)),[2,1]);
% end
% Xgeo_old=Xgeo;
% Ygeo_old=Ygeo;
% Xgeo=Xgeo_corr;
% Ygeo=Ygeo_corr;


%TIMING INFORMATION
% day=cast(hdf5read([datapath,'20170302.002_lp_1min-cal_2dVEF_001001_NoLonely-geo.h5'],'Time/Day'),'double');
% day=mean(day,1);   %average in time
% day=day(:);
% month=cast(hdf5read([datapath,'20170302.002_lp_1min-cal_2dVEF_001001_NoLonely-geo.h5'],'Time/Month'),'double');
% month=mean(month,1);
% month=month(:);
% year=cast(hdf5read([datapath,'20170302.002_lp_1min-cal_2dVEF_001001_NoLonely-geo.h5'],'Time/Year'),'double');
% year=mean(year,1);
% year=year(:);
% UThrs=cast(hdf5read([datapath,'20170302.002_lp_1min-cal_2dVEF_001001_NoLonely-geo.h5'],'Time/dtime'),'double');
% UThrs=mean(UThrs,1);
% UThrs=UThrs(:);
% UTsec=UThrs*3600;
% expdate=cat(2,year,month,day,UThrs,zeros(lt,1),zeros(lt,1));    %create a date vector for this dataset
% t=datenum(expdate);

day = 2*ones(length(outt),1);
month = 3*ones(length(outt),1);
year = 2017*ones(length(outt),1);
UThrs = outt';
expdate=cat(2,year,month,day,UThrs,zeros(lt,1),zeros(lt,1));    %create a date vector for this dataset
t=datenum(expdate);


%CONVERT POSITIONS TO GEOMAGNETIC USING SAME ALGORITHM AS SIMULATION
% glat=Ygeo;
% glon=Xgeo-360;
% gloncorrected=360+glon;
glat=Ygeo;
glon=Xgeo;
gloncorrected=glon;
% [theta,phi]=geog2geomag(glat,glon);
% mlat=90-theta*180/pi;
% mlon=phi*180/pi;


%SAMPLE THE DATA ON A UNIFORM MLAT,MLON GRID
fprintf('Interpolating...\n')

%FIND MLAT,MLON POSITION OF INPUT DATA
theta=zeros(llon,llat,lt);
phi=zeros(llon,llat,lt);
for it=1:lt
    for ilat=1:llat
        for ilon=1:llon
            [thetatmp,phitmp]=geog2geomag(glat(it,ilat,ilon),glon(it,ilat,ilon));
            theta(ilon,ilat,it)=thetatmp;
            phi(ilon,ilat,it)=phitmp;
        end
    end
end


%NUMBER OF LAT/LON POINTS FOR OUTPUT DATAS
llat2=256;
llon2=256;
% mlatdat=90-theta*180/pi;
% mlondat=phi*180/pi;
% mlatmin=min(mlatdat(:));
% mlatmax=max(mlatdat(:));
% mlat=linspace(mlatmin,mlatmax,llat2);   %use same number of points as original data
% mlonmin=min(mlondat(:));
% mlonmax=max(mlondat(:));
% mlon=linspace(mlonmin,mlonmax,llon2);
% [MLAT,MLON]=meshgrid(mlat,mlon);    %mlon goes down the vertical dimension of the matrices in this script
MLAT = squeeze(mlat(1,:,:));
MLON = squeeze(mlon(1,:,:));
mlat = linspace(min(min(MLAT)),max(max(MLAT)),llat2);
mlon = linspace(min(min(MLON)),max(max(MLON)),llon2);
theta=pi/2-mlat*pi/180;    %don't sort since we are making a glon,glat grid out of this...
phi=mlon*pi/180;

[THETA,PHI]=meshgrid(theta,phi);    %because we've arranged the data as lon,lat.
[GLAT,GLON]=geomag2geog(THETA,PHI);


%DO SPATIAL INTERPOLATIONS
Exgeomag=zeros(llon2,llat2,lt);
Eygeomag=zeros(llon2,llat2,lt);
for it=1:lt
  Extmp=squeeze(Exgeomagdat(it,:,:));
  glontemp = squeeze(gloncorrected(it,:,:))';
  glattemp = squeeze(glat(it,:,:))';
  F=TriScatteredInterp(glontemp(:),glattemp(:),Extmp(:));   %the source data are not on a plaid grid here...
  Extmp=F(GLON(:),GLAT(:));
  Exgeomag(:,:,it)=reshape(Extmp,[llon2,llat2]);
  Eytmp=squeeze(Eygeomagdat(it,:,:));
  F=TriScatteredInterp(glontemp(:),glattemp(:),Eytmp(:));
  Eygeomag(:,:,it)=reshape(F(GLON(:),GLAT(:)),[llon2,llat2]);
end


% %DEBUG PLOTTING OF ORIGINAL DATA
% plotdir='./plotsE/';
% system(['mkdir ',plotdir]);
% figure;
% set(gcf,'PaperPosition',[0 0 8.5 3.5]);
% for it=1:lt
%     clf;
%     subplot(131);
%     quiver(gloncorrected,glat,Exgeog(:,:,it),Eygeog(:,:,it));
%     xlabel('geographic lon.');
%     ylabel('geographic lat.');
%     title(datestr(datenum(expdate(it,:))));
%     
%     subplot(132);
%     quiver(GLON,GLAT,Exgeomag(:,:,it),Eygeomag(:,:,it));
%     xlabel('geog. lon. (resamp.)');
%     ylabel('geog. lat. (resamp.)');
%     title(datestr(datenum(expdate(it,:))));
% 
%     subplot(133);
% %    quiver(MLON,MLAT,Exgeomag(:,:,it),Eygeomag(:,:,it));
%     quiver(MLON',MLAT',Exgeomag(:,:,it)',Eygeomag(:,:,it)');
%     xlabel('geomagnetic lon.');
%     ylabel('geomagnetic lat.');
%     title(datestr(datenum(expdate(it,:))));    
%     
%     UTsec=expdate(it,4)*3600+expdate(it,5)*60+expdate(it,6);
%     ymd=expdate(it,1:3);
%     filename=datelab(ymd,UTsec);
%     filename=[plotdir,filename,'.png']
%     
%     print('-dpng',filename,'-r300')
% end
% close all;


%NEED TO SAMPLE DATA ON A UNIFORM TEMPORAL GRID FOR THE MODEL
%samplerate=min(diff(t));    %sampling rate in days, this uses the min from the dataset
% samplerate=10/86400;    %sampling rate in days
samplerate=1/86400;
sampleratesec=samplerate*86400;
sampleratesec=round(sampleratesec);
samplerate=sampleratesec/86400;
%outputt=min(t):samplerate:max(t);    %spans data set
%TOIstartdate=[2017,03,02,28200/3600,0,0];    %pick start and end times for the field data times of interest
%TOIenddate=[2017,03,02,28797/3600,0,0];
TOIstartdate=[2017,03,02,outt(1),0,0];    %pick start and end times for the field data times of interest
TOIenddate=[2017,03,02,outt(length(outt)),0,0];
TOIstartt=datenum(TOIstartdate);
TOIendt=datenum(TOIenddate);
outputt=TOIstartt:samplerate:TOIendt+samplerate;
outputdate=datevec(outputt);
ltout=numel(outputt);
Exit=zeros(llon2,llat2,ltout);
Eyit=zeros(llon2,llat2,ltout);
for ilat=1:llat2
   for ilon=1:llon2
       Exhere=squeeze(Exgeomag(ilon,ilat,:));
       inds=find(isnan(Exhere));
       Exhere(inds)=0;    %assumes the simulation is not encapsulating the entire domain of the electric field data
       Eyhere=squeeze(Eygeomag(ilon,ilat,:));
       inds=find(isnan(Eyhere));
       Eyhere(inds)=0;
       Exi=interp1(t,Exhere,outputt);
       Eyi=interp1(t,Eyhere,outputt);
       Exit(ilon,ilat,:)=reshape(Exi,[1 1 ltout]);
       Eyit(ilon,ilat,:)=reshape(Eyi,[1 1 ltout]);       
   end
end
% for ilat=1:llat
%    for ilon=1:llon
%        Exhere=squeeze(Exgeomagdat(ilon,ilat,:));
%        inds=find(isnan(Exhere));
%        Exhere(inds)=0;    %assumes the simulation is not encapsulating the entire domain of the electric field data
%        Eyhere=squeeze(Eygeomagdat(ilon,ilat,:));
%        inds=find(isnan(Eyhere));
%        Eyhere(inds)=0;
%        Exi=interp1(t,Exhere,outputt);
%        Eyi=interp1(t,Eyhere,outputt);
%        Exit(ilon,ilat,:)=reshape(Exi,[1 1 ltout]);
%        Eyit(ilon,ilat,:)=reshape(Eyi,[1 1 ltout]);       
%    end
% end

%ZZZ - ROB PLEASE CHECK!!!!!
% %CONVERT TO V/M
% Exit=Exit*1e-3;
% Eyit=Eyit*1e-3;


% % PLOT THE INTERPOLATED DATA AS A CHECK
% figure;
% % for it=1:ltout
% for it=1:length(Exit(1,1,:))
%     clf;
%     quiver(MLON',MLAT',Exit(:,:,it)',Eyit(:,:,it)');
%     xlabel('geomagnetic lon.');
%     ylabel('geomagnetic lat.');
%     title(datestr(datenum(outputdate(it,:))));
% 
% pause()
% 
% %     UTsec=outputdate(it,4)*3600+outputdate(it,5)*60+outputdate(it,6);
% %     ymd=outputdate(it,1:3);
% %     filename=datelab(ymd,UTsec);
% %     filename=['./',filename,'.png']
% %     
% %     print('-dpng',filename,'-r300')
% end


%ADD IN THE BOUNDARY CONDITIONS
Vminx1it=zeros(llon2,llat2,ltout);
Vmaxx1it=zeros(llon2,llat2,ltout);
Vminx2it=zeros(llat2,ltout);
Vmaxx2it=zeros(llat2,ltout);
Vminx3it=zeros(llon2,ltout);
Vmaxx3it=zeros(llon2,ltout);


%SAVE THESE DATA TO APPROPRIATE FILES - LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
%FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.  THE EFIELD DATA DO
%NO NEED TO BE SMOOTHED.
filename='simsize.dat';
fid=fopen(filename,'wb');
fwrite(fid,llon2,'integer*4');
fwrite(fid,llat2,'integer*4');
fclose(fid);
filename='simgrid.dat';
fid=fopen(filename,'w');
fwrite(fid,mlon,'real*8');
fwrite(fid,mlat,'real*8');
fclose(fid);

flagdirich=1;   %if 0 data is interpreted as FAC, else we interpret it as potential
for it=1:ltout
    UTsec=outputdate(it,4)*3600+outputdate(it,5)*60+fix(outputdate(it,6));
    ymd=outputdate(it,1:3);
    filename=datelab(ymd,UTsec);
    %filename='2017_4_6_';
    filename=[filename,'.dat']
    fid=fopen(filename,'w');

    fwrite(fid,flagdirich,'real*8');
    fwrite(fid,Exit(:,:,it),'real*8');
    fwrite(fid,Eyit(:,:,it),'real*8');
    fwrite(fid,Vminx1it(:,:,it),'real*8');
    fwrite(fid,Vmaxx1it(:,:,it),'real*8');
    fwrite(fid,Vminx2it(:,it),'real*8');
    fwrite(fid,Vmaxx2it(:,it),'real*8');
    fwrite(fid,Vminx3it(:,it),'real*8');
    fwrite(fid,Vmaxx3it(:,it),'real*8');

    fclose(fid);
end


%ALSO CREATE A MATLAB OUTPUT FILE FOR GOOD MEASURE
%save([outdir,'fields.mat'],'glon','glat','mlon','mlat','GLAT','GLON','MLAT','MLON','Exit','Eyit','Exgeog','Eygeog','Vm*','outputdate');
save([outdir,'fields.mat'],'glon','glat','mlon','mlat','GLAT','GLON','MLAT','MLON','Exit','Eyit','Vm*','outputdate');


%rmpath ../../script_utils;