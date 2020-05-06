function Efield2input(t,Xgeo,Ygeo,Exgeomagdat,Eygeomagdat,griddir,outdir)


plotflag=false;


%% Load grid using API so we don't have to keep updating manually
xg=readgrid(griddir);
mlat=90-xg.theta*180/pi;
mlon=xg.phi*180/pi;


%% CONVERT POSITIONS TO GEOMAGNETIC USING SAME ALGORITHM AS SIMULATION
[lt,llon,llat]=size(Exgeomagdat);
glat=Ygeo;
glon=Xgeo;
gloncorrected=glon;


%% FIND MLAT,MLON POSITION OF INPUT DATA
fprintf('Interpolating...\n')
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


%% NUMBER OF LAT/LON POINTS FOR OUTPUT DATAS
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


%% DO SPATIAL INTERPOLATIONS
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


%DEBUG PLOTTING OF ORIGINAL DATA
if (plotflag)
    plotdir='./plotsE/';
    system(['mkdir ',plotdir]);
    figure;
    set(gcf,'PaperPosition',[0 0 8.5 3.5]);
    for it=1:lt
        clf;
        subplot(131);
        quiver(gloncorrected,glat,Exgeog(:,:,it),Eygeog(:,:,it));
        xlabel('geographic lon.');
        ylabel('geographic lat.');
        title(datestr(datenum(expdate(it,:))));
        
        subplot(132);
        quiver(GLON,GLAT,Exgeomag(:,:,it),Eygeomag(:,:,it));
        xlabel('geog. lon. (resamp.)');
        ylabel('geog. lat. (resamp.)');
        title(datestr(datenum(expdate(it,:))));
        
        subplot(133);
        %    quiver(MLON,MLAT,Exgeomag(:,:,it),Eygeomag(:,:,it));
        quiver(MLON',MLAT',Exgeomag(:,:,it)',Eygeomag(:,:,it)');
        xlabel('geomagnetic lon.');
        ylabel('geomagnetic lat.');
        title(datestr(datenum(expdate(it,:))));
        
        UTsec=expdate(it,4)*3600+expdate(it,5)*60+expdate(it,6);
        ymd=expdate(it,1:3);
        filename=datelab(ymd,UTsec);
        filename=[plotdir,filename,'.png']
        
        print('-dpng',filename,'-r300')
    end
    close all;
end %if


%% NEED TO SAMPLE DATA ON A UNIFORM TEMPORAL GRID FOR THE MODEL
fprintf("Resampling data...\n")
samplerate=1/86400;
sampleratesec=samplerate*86400;
sampleratesec=round(sampleratesec);
samplerate=sampleratesec/86400;
%TOIstartdate=[2017,03,02,outt(1),0,0];    %pick start and end times for the field data times of interest
%TOIenddate=[2017,03,02,outt(length(outt)),0,0];
%TOIstartt=datenum(TOIstartdate);
%TOIendt=datenum(TOIenddate);
TOIstartt=t(1);     %input times expected to be provided as a datenum
TOIendt=t(end);
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
        inds=find(isnan(Exi));
        Exi(inds)=0;
        Eyi=interp1(t,Eyhere,outputt);
        inds=find(isnan(Eyi));
        Eyi(inds)=0;
        Exit(ilon,ilat,:)=reshape(Exi,[1 1 ltout]);
        Eyit(ilon,ilat,:)=reshape(Eyi,[1 1 ltout]);
    end
end


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


%% ADD IN THE BOUNDARY CONDITIONS
Vminx1it=zeros(llon2,llat2,ltout);
Vmaxx1it=zeros(llon2,llat2,ltout);
Vminx2it=zeros(llat2,ltout);
Vmaxx2it=zeros(llat2,ltout);
Vminx3it=zeros(llon2,ltout);
Vmaxx3it=zeros(llon2,ltout);


%% SAVE THESE DATA TO APPROPRIATE FILES - LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
%FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.  THE EFIELD DATA DO NOT NEED TO BE SMOOTHED.
fprintf("Generating GEMINI inputs files...\n");
filename=[outdir,'simsize.dat'];
fid=fopen(filename,'wb');
fwrite(fid,llon2,'integer*4');
fwrite(fid,llat2,'integer*4');
fclose(fid);
filename=[outdir,'simgrid.dat'];
fid=fopen(filename,'w');
fwrite(fid,mlon,'real*8');
fwrite(fid,mlat,'real*8');
fclose(fid);

flagdirich=1;   %if 0 data is interpreted as FAC, else we interpret it as potential
for it=1:ltout
    UTsec=outputdate(it,4)*3600+outputdate(it,5)*60+fix(outputdate(it,6));
    ymd=outputdate(it,1:3);
    filename=datelab(ymd,UTsec);
    filename=[outdir,filename,'.dat']
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
save([outdir,'fields.mat'],'glon','glat','mlon','mlat','GLAT','GLON','MLAT','MLON','Exit','Eyit','Vm*','outputdate');

end %function