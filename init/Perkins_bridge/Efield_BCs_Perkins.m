
%REFERENCE GRID TO USE
direcconfig='./'
direcgrid= '~/simulations/Perkins_bridge_eq/';


%OUTPUT FILE LOCATION
outdir= '~/simulations/Perkins_bridge_eq/inputs/fields/'
mkdir(outdir);


%READ IN THE SIMULATION INFORMATION (MEANS WE NEED TO CREATE THIS FOR THE SIMULATION WE WANT TO DO)
if (~exist('ymd0','var'))
  cfg = gemini3d.read.config(direcconfig);
end


%CHECK WHETHER WE NEED TO RELOAD THE GRID (SO THIS ALREADY NEEDS TO BE MADE, AS WELL)
if (~exist('xg','var'))
  %WE ALSO NEED TO LOAD THE GRID FILE
  xg= gemini3d.read.grid([direcgrid,'/']);
  lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
  x1=xg.x1(3:end-2); x2=xg.x2(3:end-2); x3=xg.x3(3:end-2);
  fprintf('Grid loaded.\n');
end


%CREATE A 'DATASET' OF ELECTRIC FIELD INFO
llon=100;
llat=100;
if (xg.lx(2)==1)    %this is curvilinear-specific code
    llat=1;
elseif (xg.lx(3)==1)
    llon=1;
end


%FIND THE LX1 VALUE OF THE F-REGION IN THE MIDDLE OF THE GRID
ix2=floor(lx2/2); ix3=floor(lx3/2);
[~,ix1]=min(abs(xg.alt(:,ix2,ix3)-300e3));
altlev=squeeze(xg.alt(ix1,:,ix3));

thetamin=min(min(squeeze(xg.theta(ix1,:,:))));
thetamax=max(max(squeeze(xg.theta(ix1,:,:))));
mlatmin=90-thetamax*180/pi;
mlatmax=90-thetamin*180/pi;
mlonmin=min(min(squeeze(xg.phi(ix1,:,:))))*180/pi;
mlonmax=max(max(squeeze(xg.phi(ix1,:,:))))*180/pi;
latbuf=1/100*(mlatmax-mlatmin);
lonbuf=1/100*(mlonmax-mlonmin);
mlat=linspace(mlatmin-latbuf,mlatmax+latbuf,llat);
mlon=linspace(mlonmin-lonbuf,mlonmax+lonbuf,llon);
[MLON,MLAT]=ndgrid(mlon,mlat);
mlonmean=mean(mlon);
mlatmean=mean(mlat);


% %INTERPOLATE X2 COORDINATE ONTO PROPOSED MLON GRID
% xgmlon=squeeze(xg.phi(1,:,1)*180/pi);
% x2=interp1(xgmlon(:),xg.x2(3:lx2+2),mlon(:),'linear','extrap');


% %WIDTH OF THE DISTURBANCE
% fracwidth=1/7;
% mlatsig=fracwidth*(mlatmax-mlatmin);
% mlonsig=fracwidth*(mlonmax-mlonmin);
% sigx2=fracwidth*(max(xg.x2)-min(xg.x2));


%TIME VARIABLE (SECONDS FROM SIMULATION BEGINNING)
tmin=0;
tmax=cfg.tdur;
%lt=60;
%time=linspace(tmin,tmax,lt)';
dtfield=60;
time=tmin:dtfield:tmax;
lt=numel(time);


%SET UP TIME VARIABLES
ymd=cfg.ymd;
UTsec=cfg.UTsec0+time;     %time given in file is the seconds from beginning of hour
UThrs=UTsec/3600;
expdate=cat(2,repmat(ymd,[lt,1]),zeros(lt,1),zeros(lt,1),UThrs(:)*3600);
t=datenum(expdate);


%CREATE DATA FOR BACKGROUND ELECTRIC FIELDS
%This is understood to be at some reference altitude
E.llon=llon; E.llat=llat;
E.mlon=mlon; E.mlat=mlat;
E.Exit=zeros(llon,llat,lt);
E.Eyit=zeros(llon,llat,lt);
for it=1:lt
  E.Exit(:,:,it)=5e-3*ones(llon,llat);   %V/m, in the x2 direction
  E.Eyit(:,:,it)=5e-3*ones(llon,llat);   %x3 direction
end


%CREATE DATA FOR BOUNDARY CONDITIONS FOR POTENTIAL SOLUTION
E.flagdirich=zeros(lt);
E.Vminx1it=zeros(llon,llat,lt);
E.Vmaxx1it=zeros(llon,llat,lt);
E.Vminx2ist=zeros(llat,lt);
E.Vmaxx2ist=zeros(llat,lt);
E.Vminx3ist=zeros(llon,lt);
E.Vmaxx3ist=zeros(llon,lt);
for it=1:lt
    %ZEROS TOP CURRENT AND X3 BOUNDARIES DON'T MATTER SINCE PERIODIC
    E.flagdirich(it)=0;
    E.Vminx1it(:,:,it)=zeros(llon,llat);
    E.Vmaxx1it(:,:,it)=zeros(llon,llat);
    E.Vminx3ist(:,it)=zeros(llon,1);
    E.Vmaxx3ist(:,it)=zeros(llon,1);
    E.Vmaxx2ist(:,it)=zeros(llat,1);
    E.Vminx2ist(:,it)=zeros(llat,1);
end


%SAVE THESE DATA TO APPROPRIATE FILES - LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
%FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.  THE EFIELD DATA DO
%NOT TYPICALLY NEED TO BE SMOOTHED.
% filename=[outdir,'simsize.dat'];
% fid=fopen(filename,'w');
% fwrite(fid,llon,'integer*4');
% fwrite(fid,llat,'integer*4');
% fclose(fid);
% filename=[outdir,'simgrid.dat'];
% fid=fopen(filename,'w');
% fwrite(fid,mlon,'real*8');
% fwrite(fid,mlat,'real*8');
% fclose(fid);
% for it=1:lt
%     UTsec=expdate(it,4)*3600+expdate(it,5)*60+expdate(it,6);
%     ymd=expdate(it,1:3);
%     filename=gemini3d.datelab(datetime([ymd,0,0,UTsec]));
%     filename=strcat(outdir,filename,'.dat')
%     fid=fopen(filename,'w');
% 
%     %FOR EACH FRAME WRITE A BC TYPE AND THEN OUTPUT BACKGROUND AND BCs
%     fwrite(fid,flagdirich,'real*8');
%     fwrite(fid,E2it(:,:,it),'real*8');
%     fwrite(fid,E3it(:,:,it),'real*8');
%     fwrite(fid,Vminx1it(:,:,it),'real*8');
%     fwrite(fid,Vmaxx1it(:,:,it),'real*8');
%     fwrite(fid,Vminx2ist(:,it),'real*8');
%     fwrite(fid,Vmaxx2ist(:,it),'real*8');
%     fwrite(fid,Vminx3ist(:,it),'real*8');
%     fwrite(fid,Vmaxx3ist(:,it),'real*8');
% 
%     fclose(fid);
% end

for it=1:lt
    E.times(it)=datetime(expdate(it,:));
end %for
gemini3d.write.Efield(E,outdir,"h5")

%ALSO CREATE A MATLAB OUTPUT FILE FOR GOOD MEASURE
%save([outdir,'fields.mat'],'mlon','mlat','MLAT','MLON','E2it','E3it','Vminx*','Vmax*','expdate');
