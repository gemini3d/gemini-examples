cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils']);


%REFERENCE GRID TO USE
direcconfig='./'
direcgrid=[gemini_root,'/../simulations/input/ICI2/']


%CREATE SOME SPACE FOR OUTPUT FILES
outdir=[gemini_root,'/../simulations/input/ICI2_particles/'];
system(['mkdir ',outdir]);
system(['rm ',outdir,'/*']);


%READ IN THE SIMULATION INFORMATION (MEANS WE NEED TO CREATE THIS FOR THE SIMULATION WE WANT TO DO)
if (~exist('ymd0','var'))
  [ymd0,UTsec0,tdur,dtout,flagoutput,mloc]=readconfig([direcconfig,'/config.ini']);
  fprintf('Input config.dat file loaded.\n');
end


%CHECK WHETHER WE NEED TO RELOAD THE GRID (SO THIS ALREADY NEEDS TO BE MADE, AS WELL)
if (~exist('xg','var'))
  %WE ALSO NEED TO LOAD THE GRID FILE
  xg=readgrid([direcgrid,'/']);
  fprintf('Grid loaded.\n');
end


%REFERENCES TO GRID DISTANCES, IF NEEDED
x1=xg.x1(3:end-2);
x2=xg.x2(3:end-2);
x3=xg.x3(3:end-2);


%CREATE A 'DATASET' OF PRECIPITATION CHARACTERISTICS
llon=100;
llat=100;
if (xg.lx(2)==1)    %this is cartesian-specific code
    llon=1;
elseif (xg.lx(3)==1)
    llat=1;
end
thetamin=min(xg.theta(:));
thetamax=max(xg.theta(:));
mlatmin=90-thetamax*180/pi;
mlatmax=90-thetamin*180/pi;
mlonmin=min(xg.phi(:))*180/pi;
mlonmax=max(xg.phi(:))*180/pi;
%mlat=linspace(mlatmin,mlatmax,llat);
%mlon=linspace(mlonmin,mlonmax,llon);
latbuf=1/100*(mlatmax-mlatmin);
lonbuf=1/100*(mlonmax-mlonmin);
mlat=linspace(mlatmin-latbuf,mlatmax+latbuf,llat);
mlon=linspace(mlonmin-lonbuf,mlonmax+lonbuf,llon);
[MLON,MLAT]=ndgrid(mlon,mlat);
mlonmean=mean(mlon);
mlatmean=mean(mlat);
x2grid=linspace(min(x2),max(x2),llon);
x3grid=linspace(min(x3),max(x3),llat);
[X3,X2]=meshgrid(x3grid,x2grid);


%WIDTH OF THE DISTURBANCE
%mlatsig=1/10*(mlatmax-mlatmin);
%mlatsig=max(mlatsig,0.01);    %can't let this go to zero...
%mlonsig=1/10*(mlonmax-mlonmin);
mlatsig=1/10*(mlatmax-mlatmin);
mlatsig=max(mlatsig,0.01);    %can't let this go to zero...
mlonsig=1/3*(mlonmax-mlonmin);


%TIME VARIABLE (SECONDS FROM SIMULATION BEGINNING)
tmin=0;
tmax=tdur;
%lt=tdur+1;
%time=linspace(tmin,tmax,lt)';
time=tmin:0.5:tmax;
lt=numel(time);


%COMPUTE THE TOTAL ENERGY FLUX AND CHAR. ENERGY
%{
Q=zeros(lt,llon,llat);
E0=zeros(lt,llon,llat);
for it=1:lt
  Qtmp=squeeze(Qdat(it,:,:));
  Qtmp=interp2(glat,gloncorrected,Qtmp,GLAT(:),GLON(:));    %data are plaid in geographic so do the interpolation in that variable
  Q(it,:,:)=reshape(Qtmp,[1 llon llat]);
  E0tmp=squeeze(E0dat(it,:,:));
  E0tmp=interp2(glat,gloncorrected,E0tmp,GLAT(:),GLON(:));    %data are plaid in geographic so do the interpolation in that variable
  E0(it,:,:)=reshape(E0tmp,[1 llon llat]);  
end
%}


%SET UP TIME VARIABLES
ymd=ymd0;
UTsec=UTsec0+time;     %time given in file is the seconds from beginning of hour
UThrs=UTsec/3600;
expdate=cat(2,repmat(ymd,[lt,1]),UThrs(:),zeros(lt,1),zeros(lt,1));
t=datenum(expdate);

%{
%INTERPOLATE/DECIMATE TO 1 SECOND RESOLUTION
samplerate=1;    %sampling rate in seconds
startdate=[ymd0,UTsec0/3600,0,0];
startt=datenum(startdate);
%tmin=ceil(min(t)*86400)/86400;
tmin=ceil(startt*86400)/86400;
tmax=floor(max(t)*86400)/86400;
outputt=tmin:samplerate/86400:tmax;
outputdate=datevec(outputt);
ltout=numel(outputt);
Qit=zeros(llon,llat,ltout);
E0it=zeros(llon,llat,ltout);
for ilat=1:llat
   for ilon=1:llon
       Qhere=squeeze(Qsmooth(:,ilon,ilat));
       E0here=squeeze(E0smooth(:,ilon,ilat));
       Qi=interp1(t,Qhere,outputt);
       E0i=interp1(t,E0here,outputt);
       Qit(ilon,ilat,:)=reshape(Qi,[1 1 ltout]);
       E0it(ilon,ilat,:)=reshape(E0i,[1 1 ltout]);       
   end
end
%}


%CREATE THE PRECIPITAITON INPUT DATA
Qit=zeros(llon,llat,lt);
E0it=zeros(llon,llat,lt);
% frequency; 0.2Hz, assume temporal
period=5;
omega=2*pi/period;
%wavelenth; 5km, assume spatial
lambda=5e3;
k=2*pi/lambda;
Q0=0.5;    %mW/m2
for it=1:lt
   %Temporal
   %Qit(:,:,it)=(Q0+0.3*Q0*sin(omega*(t(it)-t(1))*86400))*exp(-(MLON-mlonmean).^2/2/mlonsig^2).*exp(-(MLAT-mlatmean).^2/2/mlatsig^2);            %mW/m^2
   %E0it(:,:,it)=(150+0.3*150*sin(omega*(t(it)-t(1))*86400))*exp(-(MLON-mlonmean).^2/2/mlonsig^2).*exp(-(MLAT-mlatmean).^2/2/mlatsig^2);     %150eV background + 30% variation

   %Spatial
   Qit(:,:,it)=(Q0+0.3*Q0*cos(k*X2)).*exp(-(MLON-mlonmean).^2/2/mlonsig^2).*exp(-(MLAT-mlatmean).^2/2/mlatsig^2);            %mW/m^2
   E0it(:,:,it)=(150+0.3*150*cos(k*X2)).*exp(-(MLON-mlonmean).^2/2/mlonsig^2).*exp(-(MLAT-mlatmean).^2/2/mlatsig^2);     %150eV background + 30% variation
end



%%CONVER THE ENERGY TO EV
%E0it=max(E0it,0.100);
%E0it=E0it*1e3;



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
for it=1:lt
    UTsec=expdate(it,4)*3600+expdate(it,5)*60+expdate(it,6);
    ymd=expdate(it,1:3);
    filename=datelab(ymd,UTsec);
    filename=[outdir,filename,'.dat']
    fid=fopen(filename,'w');
    fwrite(fid,Qit(:,:,it),'real*8');
    fwrite(fid,E0it(:,:,it),'real*8');
    fclose(fid);
end


%ALSO SAVE TO A  MATLAB FILE
save([outdir,'particles.mat'],'mlon','mlat','Qit','E0it','expdate');


%RESTORE PATH
%rmpath ./restore_idl;
%rmpath ../../script_utils;
