%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS PROGRAM REQUIRES THE RESTORE_IDL SCRIPTS WHICH CAN BE DOWNLOADED FROM THE
% MATLAB FILE EXCHANGE AT:
%   https://www.mathworks.com/matlabcentral/fileexchange/43899-restore-idl
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
flagplots=0;

% cwd = fileparts(mfilename('fullpath'));
% gemini_root = [cwd, filesep, '../../../GEMINI'];
% addpath([gemini_root, filesep, 'script_utils'])
% addpath([gemini_root, filesep, 'setup/gridgen'])
% addpath([gemini_root, filesep, 'setup'])
% addpath([gemini_root, filesep, 'vis'])
addpath ~/Dropbox/common/mypapers/ISINGLASS/AGU2017/restore_idl/;
% %clear


%FLAGS CONTROLLING WHETHER WE ARE PLOTTING/SMOOTHING, ETC.


%MINIMUM ALLOWABLE CHARACTERISTIC ENERGY
minE0=1;    %keV
maxE0=15;


%CREATE SOME SPACE FOR OUTPUT FILES
outdir='~/simulations/input/particles_isinglass_grubbs_final_new/';
system(['mkdir ',outdir]);
system(['rm -rvf ',outdir,'/*']);   %clean out existing files


%READ IN THE IDL SAVE FILE - THIS IS THE FORMAT NORMALLY GIVEN TO ME BY GUY GRUBBS
firstrun=0;
if (~exist('Qdat','var'))
    %datapath='~/articles/clayton/';
    datapath='~/Dropbox/common/mypapers/ISINGLASS/AGU2017/';
    %fname='isinglass_eflux_asi_highres.sav';
    fname='isinglass_eflux_asi_full.sav';    %this contains the spatial offset correction...
    %fname='isinglass_eflux_MB-2.sav';
    %fname='isinglass_eflux_asi_resync.sav';
    outargs=restore_idl([datapath,fname]);
    time=double(outargs.NEW_TIME);
%    time = [0:3598.8/11922:3598.8]';    %Rob's fix for the time variable...
    lat=double(outargs.NEW_LAT);
    lon=double(outargs.NEW_LON);
    Qdat=double(outargs.RESAMP_Q);
    E0dat=double(outargs.RESAMP_EO);
    [lt,llon0,llat0]=size(Qdat);

    %clean out nans from Qdat
    inds=find(isnan(Qdat));
    Qdat(inds)=0;
    E0dat(inds)=minE0;

    %floor E0 at 1keV
    E0dat=max(E0dat,minE0);
    E0dat=min(E0dat,maxE0);

    firstrun=1;

    if (time(1)<7)
        time=time+7*3600;   %some of the input files have time starting from 7UT
    end %if

    datadate=[2017*ones(lt,1),03*ones(lt,1),02*ones(lt,1),time(:)/3600,zeros(lt,1),zeros(lt,1)];     %define a date structure for the input data

    load([datapath,'isinglass_clayton_grid.mat']);
    clear glon glat

    %GEOGRAPHIC AND POSITIONS OF DATA - SORT ACCORDING TO LONGITUDE, ETC.
%    glat=lat;
%    glon=lon;
%    gloncorrected=glon+360;    %for interpolations which won't understand periodic coordinate
    %GEOGRAPHIC AND MAGNETIC POSITIONS OF DATA
    glat=lat;
    glon=lon;
    gloncorrected=glon+360;    %for interpolations which won't understand periodic coordinate

    [gloncorrected,isort]=sort(gloncorrected);    %to insure that the longitude coordinate runs in the right direction
    Qdat=Qdat(:,isort,:);
    E0dat=E0dat(:,isort,:);
    glon=glon(isort);

    %COMPUTE THETA,PHI COORDINATES FOR THE DATA LOCATIONS
    thetadat=zeros(llon0,llat0);
    phidat=zeros(llon0,llat0);
    for ilat=1:llat0
        for ilon=1:llon0
            [thetatmp,phitmp]=geog2geomag(glat(ilat),glon(ilon));
            thetadat(ilon,ilat)=thetatmp;
            phidat(ilon,ilat)=phitmp;
        end
    end
end



%VISUALIZE ORIGINAL DATA
if (flagplots)
  plotdir=[outdir,'/plots_orig/'];
  system(['mkdir ',plotdir]);
  figure;
  %set(gcf,'PaperPosition',[0 0 8.5 3.5]);
  parfor it=1:lt
      clf;
      subplot(121);
      imagesc(glon,glat,squeeze(Qdat(it,:,:))');    %transpose since we are doing lon,lat as 1,2 dims.
      axis xy;
      axis tight;
      ylabel('glat.');
      xlabel('glon.');
      title(['Original Q:  ',datestr(datenum(datadate(it,:)))]);
      colorbar;

      subplot(122);
      imagesc(glon,glat,squeeze(E0dat(it,:,:))');
      axis xy;
      axis tight;
      ylabel('glat.');
      xlabel('glon.');
      title(['Original E_0:  ',datestr(datenum(datadate(it,:)))]);
      colorbar;

      UTsec=datadate(it,4)*3600+datadate(it,5)*60+datadate(it,6);
      ymd=datadate(it,1:3);
      filename=datelab(ymd,UTsec);
      filename=[plotdir,filename,'.png']

      print('-dpng',filename,'-r300')
  end
  close all;
end


%APPLY SOME SMOOTHING - IT'S ACTUALLY BETTER TO SMOOTH BEFORE THE ROTATION STEP SINCE THERE ARE SOME FLOORED AND MISSING VALUES THAT ARE DISCONTINUOUS...
fprintf('Smoothing longitude...\n');
Qsmooth=zeros(lt,llon0,llat0);
E0smooth=zeros(lt,llon0,llat0);
for it=1:lt
    %it
    for ilat=1:llat0
        Qtmp=squeeze(Qdat(it,:,ilat));
        inds=find(isnan(Qtmp));
        Qtmp(inds)=0;
        Qtmp=smooth(Qtmp,4);
        Qsmooth(it,:,ilat)=reshape(Qtmp,[1,llon0,1]);
        E0tmp=squeeze(E0dat(it,:,ilat));
        inds=find(isnan(E0tmp));
        E0tmp(inds)=0;
        E0tmp=smooth(E0tmp,4);
        E0smooth(it,:,ilat)=reshape(E0tmp,[1,llon0,1]);
    end
end

fprintf('Smoothing latitude...\n');
for it=1:lt
    %it
    for ilon=1:llon0
        Qtmp=smooth(squeeze(Qsmooth(it,ilon,:)),4);
        Qsmooth(it,ilon,:)=reshape(Qtmp,[1,1,llat0]);
        E0tmp=smooth(squeeze(E0smooth(it,ilon,:)),4);
        E0smooth(it,ilon,:)=reshape(E0tmp,[1,1,llat0]);
    end
end

fprintf('Smoothing time...\n');
for ilat=1:llat0
    %ilat
    for ilon=1:llon0
        Qtmp=smooth(squeeze(Qsmooth(:,ilon,ilat)),5);
        Qsmooth(:,ilon,ilat)=reshape(Qtmp,[lt,1,1]);
        E0tmp=smooth(squeeze(E0smooth(:,ilon,ilat)),10);    %data are noisier than the total energy flux
        E0smooth(:,ilon,ilat)=reshape(E0tmp,[lt,1,1]);
    end
end


%VISUALIZE SMOOTHED DATA
if (flagplots)
  plotdir=[outdir,'/plots_smooth/'];
  system(['mkdir ',plotdir]);
  figure;
  %set(gcf,'PaperPosition',[0 0 8.5 3.5]);
  parfor it=1:lt
      clf;
      subplot(121);
      imagesc(glon,glat,squeeze(Qsmooth(it,:,:))');    %transpose since we are doing lon,lat as 1,2 dims.
      axis xy;
      axis tight;
      ylabel('glat.');
      xlabel('glon.');
      title(['Smoothed Q:  ',datestr(datenum(datadate(it,:)))]);
      colorbar;

      subplot(122);
      imagesc(glon,glat,squeeze(E0smooth(it,:,:))');
      axis xy;
      axis tight;
      ylabel('glat.');
      xlabel('glon.');
      title(['Smoothed E_0:  ',datestr(datenum(datadate(it,:)))]);
      colorbar;

      UTsec=datadate(it,4)*3600+datadate(it,5)*60+datadate(it,6);
      ymd=datadate(it,1:3);
      filename=datelab(ymd,UTsec);
      filename=[plotdir,filename,'.png']

      print('-dpng',filename,'-r300')
  end
  close all;
end


%RESAMPLE DATA ON AN MLAT MLON GRID OF THE SAME SIZE AS THE ORIGINAL - THIS
%IS EFFECTIVELY JUST A COORDINATE TRANSFORMATION/ROTATION STEP...
%thetadat,phidat]=geog2geomag(glat,glon);
mlatdat=90-thetadat*180/pi;
mlondat=phidat*180/pi;
mlatdatgrid=linspace(min(mlatdat(:)),max(mlatdat(:)),llat0);    %these automatically order the mlat/mlon-datgrid arrays
mlondatgrid=linspace(min(mlondat(:)),max(mlondat(:)),llon0);
thetadatgrid=pi/2-mlatdatgrid*pi/180;     %leave unsorted because we plot vs. mlat and vectors are already arranged this way
%thetadatgrid=sort(thetadatgrid);
phidatgrid=mlondatgrid*pi/180;
[THETADATGRID,PHIDATGRID]=meshgrid(thetadatgrid,phidatgrid);    %theta is the x2 (x) coordinate
GLONDATGRID=zeros(llon0,llat0);    %should be approximately the same size as the original data in order to prevent artifacts from rotation
GLATDATGRID=zeros(llon0,llat0);
for ilat=1:llat0
    for ilon=1:llon0
      [glattmp,glontmp]=geomag2geog(THETADATGRID(ilon,ilat),PHIDATGRID(ilon,ilat));
      GLATDATGRID(ilon,ilat)=glattmp;
      GLONDATGRID(ilon,ilat)=glontmp;
    end
end
Qdatmag=zeros(lt,llon0,llat0);
E0datmag=zeros(lt,llon0,llat0);
fprintf('Spatial rotation/interpolation step...\n');
for it=1:lt
  Qtmp=squeeze(Qsmooth(it,:,:));
  Qtmp=interp2(glat,gloncorrected,Qtmp,GLATDATGRID(:),GLONDATGRID(:));    %data are plaid in geographic so do the interpolation in that variable
  Qdatmag(it,:,:)=reshape(Qtmp,[1 llon0 llat0]);
  E0tmp=squeeze(E0smooth(it,:,:));
  E0tmp=interp2(glat,gloncorrected,E0tmp,GLATDATGRID(:),GLONDATGRID(:));
  E0datmag(it,:,:)=reshape(E0tmp,[1 llon0 llat0]);
end



%VISUALIZE THE ROTATED DATA
if (flagplots)
  plotdir=[outdir,'/plots_rot/'];
  system(['mkdir ',plotdir]);
  figure;
  %set(gcf,'PaperPosition',[0 0 8.5 3.5]);
  parfor it=1:lt
      clf;
      subplot(121);
      imagesc(mlondatgrid,mlatdatgrid,squeeze(Qdatmag(it,:,:))');    %transpose since we are doing lon,lat as 1,2 dims.
      axis xy;
      axis tight;
      ylabel('mlat.');
      xlabel('mlon.');
      title(['Rotated Q:  ',datestr(datenum(datadate(it,:)))]);
      colorbar;

      subplot(122);
      imagesc(mlondatgrid,mlatdatgrid,squeeze(E0datmag(it,:,:))');
      axis xy;
      axis tight;
      ylabel('mlat.');
      xlabel('mlon.');
      title(['Rotated E_0:  ',datestr(datenum(datadate(it,:)))]);
      colorbar;

      UTsec=datadate(it,4)*3600+datadate(it,5)*60+datadate(it,6);
      ymd=datadate(it,1:3);
      filename=datelab(ymd,UTsec);
      filename=[plotdir,filename,'.png']

      print('-dpng',filename,'-r300')
  end
  close all;
end


%SET UP TIME VARIABLES
%ymd=[2017,03,02];
%UTsec=7*3600+time;     %time given in file is the seconds from beginning of hour
%UThrs=UTsec/3600;
%datadate=cat(2,repmat(ymd,[lt,1]),UThrs(:),zeros(lt,1),zeros(lt,1));
t=datenum(datadate);


%NUMBER OF LAT/LON POINTS FOR OUTPUT DATA - BASED ON GRID INFORMATION IN isinglass_clayton_grid.mat
llat=256;
llon=256;
MLAT = squeeze(mlat(1,:,:));    %upsample onto the actual grid to be used...
MLON = squeeze(mlon(1,:,:));
mlat = linspace(min(min(MLAT)),max(max(MLAT)),llat);
mlon = linspace(min(min(MLON)),max(max(MLON)),llon);
%mlat=linspace(min(mlatdatgrid),max(mlatdatgrid),llat);    %upsample for entire space, for purposes of plotting the results.
%mlon=linspace(min(mlondatgrid),max(mlondatgrid),llon);
[MLAT,MLON]=meshgrid(mlat,mlon);
Q=zeros(lt,llon,llat);
E0=zeros(lt,llon,llat);
fprintf('Spatial upsampling step...\n');
for it=1:lt
  Qtmp=squeeze(Qdatmag(it,:,:));
  Qtmp=interp2(mlatdatgrid,mlondatgrid,Qtmp,MLAT(:),MLON(:),'cubic');    %data are plaid in geographic so do the interpolation in that variable
  Q(it,:,:)=reshape(Qtmp,[1 llon llat]);
  E0tmp=squeeze(E0datmag(it,:,:));
  E0tmp=interp2(mlatdatgrid,mlondatgrid,E0tmp,MLAT(:),MLON(:),'cubic');    %data are plaid in geographic so do the interpolation in that variable
  E0(it,:,:)=reshape(E0tmp,[1 llon llat]);
end


%SAFETY CHECKS FOR NEGATIVE ENERGY FLUX AND E0
inds=find(E0(:)<minE0);
E0(inds)=minE0;
inds=find(Q(:)<0.025);
Q(inds)=0.025;



%VISUALIZE THE UPSAMPLED DATA
if (flagplots)
  plotdir=[outdir,'/plots/'];
  system(['mkdir ',plotdir]);
  figure;
  parfor it=1:lt
      clf;
      subplot(121);
      imagesc(mlon,mlat,squeeze(Q(it,:,:))');    %transpose since we are doing lon,lat as 1,2 dims.
      axis xy;
      axis tight;
      ylabel('mlat.');
      xlabel('mlon.');
      title(['Interpolated Q:  ',datestr(datenum(datadate(it,:)))]);
      colorbar;

      subplot(122);
      imagesc(mlon,mlat,squeeze(E0(it,:,:))');
      axis xy;
      axis tight;
      ylabel('mlat.');
      xlabel('mlon.');
      title(['Interpolated E_0:  ',datestr(datenum(datadate(it,:)))]);
      colorbar;

      UTsec=datadate(it,4)*3600+datadate(it,5)*60+datadate(it,6);
      ymd=datadate(it,1:3);
      filename=datelab(ymd,UTsec);
      filename=[plotdir,filename,'.png']

      print('-dpng',filename,'-r300')
  end
  close all;
end


%MAKE A SECOND PASS WITH THE SMOOTH TO ELIMINATE BLOCK ARTIFACTS FROM PIECEWISE INTERPOLATION OF LOWRES DATA
fprintf('2nd pass, smoothing longitude...\n');
Qsmooth=zeros(lt,llon,llat);
E0smooth=zeros(lt,llon,llat);
for it=1:lt
    %it
    for ilat=1:llat
        Qtmp=squeeze(Q(it,:,ilat));
        inds=find(isnan(Qtmp));
        Qtmp(inds)=0;
        Qtmp=smooth(Qtmp,20);
        Qsmooth(it,:,ilat)=reshape(Qtmp,[1,llon,1]);
        E0tmp=squeeze(E0(it,:,ilat));
        inds=find(isnan(E0tmp));
        E0tmp(inds)=0;
        E0tmp=smooth(E0tmp,20);
        E0smooth(it,:,ilat)=reshape(E0tmp,[1,llon,1]);
    end
end

fprintf('2nd pass, smoothing latitude...\n');
for it=1:lt
    %it
    for ilon=1:llon
        Qtmp=smooth(squeeze(Qsmooth(it,ilon,:)),20);
        Qsmooth(it,ilon,:)=reshape(Qtmp,[1,1,llat]);
        E0tmp=smooth(squeeze(E0smooth(it,ilon,:)),20);
        E0smooth(it,ilon,:)=reshape(E0tmp,[1,1,llat]);
    end
end

fprintf('2nd pass, smoothing time...\n');
for ilat=1:llat
    %ilat
    for ilon=1:llon
        Qtmp=smooth(squeeze(Qsmooth(:,ilon,ilat)),12);
        Qsmooth(:,ilon,ilat)=reshape(Qtmp,[lt,1,1]);
        E0tmp=smooth(squeeze(E0smooth(:,ilon,ilat)),22);    %data are noisier than the total energy flux
        E0smooth(:,ilon,ilat)=reshape(E0tmp,[lt,1,1]);
    end
end


%OVERWRITE THE UNSMOOTHED DATA FOR RESAMPLING
Q=Qsmooth;
E0=E0smooth;


%VISUALIZE THE DATA AFTER THE SECOND SMOOTHING PASS
if (flagplots)
  plotdir=[outdir,'/plots_2ndsmooth/'];
  system(['mkdir ',plotdir]);
  figure;
  parfor it=1:lt
      clf;
      subplot(121);
      imagesc(mlon,mlat,squeeze(Q(it,:,:))');    %transpose since we are doing lon,lat as 1,2 dims.
      axis xy;
      axis tight;
      ylabel('mlat.');
      xlabel('mlon.');
      title(['2nd smoothing pass Q:  ',datestr(datenum(datadate(it,:)))]);
      colorbar;

      subplot(122);
      imagesc(mlon,mlat,squeeze(E0(it,:,:))');
      axis xy;
      axis tight;
      ylabel('mlat.');
      xlabel('mlon.');
      title(['2nd smoothing pass E_0:  ',datestr(datenum(datadate(it,:)))]);
      colorbar;

      UTsec=datadate(it,4)*3600+datadate(it,5)*60+datadate(it,6);
      ymd=datadate(it,1:3);
      filename=datelab(ymd,UTsec);
      filename=[plotdir,filename,'.png']

      print('-dpng',filename,'-r300')
  end
  close all;
end



%INTERPOLATE/DECIMATE TO 1 SECOND RESOLUTION
samplerate=1;    %sampling rate in seconds
%samplerate=0.5;
%for 0700 run
% startdate=[2017,3,2,7,0,0];
% startt=datenum(startdate);
% tmin=ceil(startt*86400)/86400;
% tmax=floor(t(2000)*86400)/86400;

%for rocket run 0750
fprintf('Resampling in time...\n');
startdate=[2017,3,2,7,0,0];
startt=datenum(startdate);
tmin=ceil(startt*86400)/86400;
tmax=floor(max(t)*86400)/86400;
outputt=tmin:samplerate/86400:tmax;
outputdate=datevec(outputt);
ltout=numel(outputt);
Qit=zeros(llon,llat,ltout);
E0it=zeros(llon,llat,ltout);
for ilat=1:llat
   for ilon=1:llon
       Qhere=squeeze(Q(:,ilon,ilat));
       E0here=squeeze(E0(:,ilon,ilat));
       Qi=interp1(t,Qhere,outputt);
       E0i=interp1(t,E0here,outputt);
       Qit(ilon,ilat,:)=reshape(Qi,[1 1 ltout]);
       E0it(ilon,ilat,:)=reshape(E0i,[1 1 ltout]);
   end
end


% %PLOT THE DECIMATED DATA
% plotdir='./plots_decimated/';
% system(['mkdir ',plotdir]);
% figure;
% for it=1:ltout
%     clf;
%     imagesc(mlon,mlat,squeeze(Qit(:,:,it))');
%     axis xy; axis square;
%     ylabel('mlat.');
%     xlabel('mlon.');
%     title(['Decimated:  ',datestr(datenum(outputdate(it,:)))]);
%     colorbar;
%     cax=caxis;
%     caxis([0 40]);
%
%     UTsec=outputdate(it,4)*3600+outputdate(it,5)*60+outputdate(it,6);
%     ymd=outputdate(it,1:3);
%     filename=datelab(ymd,UTsec);
%     filename=[plotdir,filename,'.png']
%
%     print('-dpng',filename,'-r300')
% end
% close all;


%CONVER THE ENERGY TO EV
%E0it=max(E0it,1);
E0it=E0it*1e3;


%SAVE THIS DATA TO APPROPRIATE FILES - LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
%FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.  THE EFIELD DATA DO
%NO NEED TO BE SMOOTHED.
filename=[outdir,'simsize.dat'];
fid=fopen(filename,'w');
fwrite(fid,llon,'integer*4');
fwrite(fid,llat,'integer*4');
fclose(fid);
filename=[outdir,'simgrid.dat'];
fid=fopen(filename,'w');
fwrite(fid,mlon,'real*8');
fwrite(fid,mlat,'real*8');
fclose(fid);
for it=1:ltout
    UTsec=outputdate(it,4)*3600+outputdate(it,5)*60+outputdate(it,6);
    ymd=outputdate(it,1:3);
    filename=datelab(ymd,UTsec);
    filename=[outdir,filename,'.dat']
    fid=fopen(filename,'w');
    fwrite(fid,Qit(:,:,it),'real*8');
    fwrite(fid,E0it(:,:,it),'real*8');
    fclose(fid);
end


%ALSO SAVE TO A  MATLAB FILE
save('-v7.3',[outdir,'particles.mat'],'glon','glat','mlon','mlat','Qit','E0it','outputdate');
