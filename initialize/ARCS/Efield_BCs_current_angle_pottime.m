cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils']);
addpath([gemini_root, filesep, 'vis']);


direcconfig='./'
direcgrid=[gemini_root,filesep,'../simulations/input/ARCS/'];
direc='~/zettergmdata/simulations/ARCS_angle/'


%OUTPUT FILE LOCATION
outdir=[gemini_root,filesep,'../simulations/input/ARCS_fields/'];
mkdir([outdir]);


%READ IN THE SIMULATION INFORMATION (MEANS WE NEED TO CREATE THIS FOR THE SIMULATION WE WANT TO DO)
if (~exist('ymd0','var'))
  [ymd0,UTsec0,tdur,dtout,flagoutput,mloc]=readconfig([direcconfig,'/config.ini']);
  fprintf('Input config.dat file loaded.\n');
end


%CHECK WHETHER WE NEED TO RELOAD THE GRID (SO THIS ALREADY NEEDS TO BE MADE, AS WELL)
if (~exist('xg','var'))
 xg=readgrid([direcgrid,'/']);
 lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
 fprintf('Grid loaded.\n');
end


%LOAD A REFERENCE POTENTIAL FROM AN EXISTING SIMULATION THAT USED NEUMANN BOUNDARY CONDITIONS
t=0;
dtfile=10;    %can hard-code instead of using the simulation dtout
UTsec=UTsec0;
ymd=ymd0;
it=1;
while(t<=tdur)
  [ne,mlatsrc,mlonsrc,xg,v1,Ti,Te,J1,v2,v3,J2,J3,filename,Phitop]=loadframe(direc,ymd,UTsec,ymd0,UTsec0,tdur,dtout,flagoutput,mloc,xg);
  refpotential(:,:,it)=Phitop;    %this is the FAC off of which we base our new inputs files
  [ymd,UTsec]=dateinc(dtfile,ymd,UTsec);
  it=it+1;
  t=t+dtfile;
end %while


%INTERPOLATION IS DONE IN MLON AND MLAT
MLAT=90-squeeze(xg.theta(1,:,:))*180/pi;
MLON=squeeze(xg.phi(1,:,:))*180/pi;
llon=xg.lx(2);
llat=xg.lx(3);
mlon=MLON(:,1);    %the only downside here is that it clips off the end of the BC
mlat=MLAT(1,:);


%TIME VARIABLE (SECONDS FROM SIMULATION BEGINNING)
tmin=0;
tmax=tdur;
time=tmin:dtfile:tmax;     %needs to be at the same cadence as the data that we are reading in
lt=numel(time);


%SET UP TIME VARIABLES
ymd=ymd0;
UTsec=UTsec0+time;     %time given in file is the seconds from beginning of hour
UThrs=UTsec/3600;
expdate=cat(2,repmat(ymd,[lt,1]),UThrs(:),zeros(lt,1),zeros(lt,1));
t=datenum(expdate);


%CREATE DATA FOR BACKGROUND ELECTRIC FIELDS
Exit=zeros(llon,llat,lt);
Eyit=zeros(llon,llat,lt);
for it=1:lt
  Exit(:,:,it)=zeros(llon,llat);   %V/m
  Eyit(:,:,it)=25e-3*ones(llon,llat);
end



%CREATE DATA FOR BOUNDARY CONDITIONS FOR POTENTIAL SOLUTION
flagdirich=1;   %use the potential pattern given by the user (does this take into account background field???)
Vminx1it=zeros(llon,llat,lt);
Vmaxx1it=zeros(llon,llat,lt);
Vminx2ist=zeros(llat,lt);
Vmaxx2ist=zeros(llat,lt);
Vminx3ist=zeros(llon,lt);
Vmaxx3ist=zeros(llon,lt);


%ARCS example
for it=1:lt
    %ZEROS TOP CURRENT AND X3 BOUNDARIES DON'T MATTER SINCE PERIODIC
    Vminx1it(:,:,it)=zeros(llon,llat);
    if (it>2)
      Vmaxx1it(:,:,it)=refpotential(:,:,it);
    else
      Vmaxx1it(:,:,it)=zeros(llon,llat);
    end
%    if (it>2)
%      Vmaxx1it(:,:,it)=Jpk.*exp(-(MLON-mlonmean).^2/2/mlonsig^2).*exp(-(MLAT-mlatctr-1.5*mlatsig).^2/2/mlatsig^2);
%      Vmaxx1it(:,:,it)=Vmaxx1it(:,:,it)-Jpk.*exp(-(MLON-mlonmean).^2/2/mlonsig^2).*exp(-(MLAT-mlatctr+1.5*mlatsig).^2/2/mlatsig^2);
%    else
%      Vmaxx1it(:,:,it)=zeros(llon,llat);
%    end
    Vminx2ist(:,it)=zeros(llat,1);     %these are just slices
    Vmaxx2ist(:,it)=zeros(llat,1);
    Vminx3ist(:,it)=zeros(llon,1);
    Vmaxx3ist(:,it)=zeros(llon,1);
end


%SAVE THESE DATA TO APPROPRIATE FILES - LEAVE THE SPATIAL AND TEMPORAL INTERPOLATION TO THE
%FORTRAN CODE IN CASE DIFFERENT GRIDS NEED TO BE TRIED.  THE EFIELD DATA DO
%NOT TYPICALLY NEED TO BE SMOOTHED.
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
    
    %FOR EACH FRAME WRITE A BC TYPE AND THEN OUTPUT BACKGROUND AND BCs
    fwrite(fid,flagdirich,'real*8');
    fwrite(fid,Exit(:,:,it),'real*8');
    fwrite(fid,Eyit(:,:,it),'real*8');
    fwrite(fid,Vminx1it(:,:,it),'real*8');
    fwrite(fid,Vmaxx1it(:,:,it),'real*8');  
    fwrite(fid,Vminx2ist(:,it),'real*8');
    fwrite(fid,Vmaxx2ist(:,it),'real*8'); 
    fwrite(fid,Vminx3ist(:,it),'real*8');
    fwrite(fid,Vmaxx3ist(:,it),'real*8');     
   
    fclose(fid);
end


%ALSO CREATE A MATLAB OUTPUT FILE FOR GOOD MEASURE
save([outdir,'fields.mat'],'mlon','mlat','MLAT','MLON','Exit','Eyit','Vminx*','Vmax*','expdate');

