%% Set paths to other GEMINI repos
cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'vis'])
addpath([gemini_root, filesep, 'script_utils']);
addpath([gemini_root, filesep, 'setup/gridgen']);
addpath([gemini_root, filesep, '../GEMINI-scripts/setup/gridgen']);
addpath([gemini_root, filesep, 'setup']);
geminiscripts_root = [cwd, filesep, '../../../GEMINI-scripts'];
addpath([geminiscripts_root,filesep,'setup/gridgen']);


%% EQuatorial grid
dtheta=5.70;
dphi=10;
lp=256;
lq=384;
lphi=128;
altmin=80e3;
glat=12;
glon=360-76.9;     %Jicamarca
gridflag=1;
flagsource=0;
iscurv=true;


%% MATLAB GRID GENERATION
if (~exist('xg'))
    xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end %if
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%IDENTIFICATION FOR THE NEW SIMULATION THAT IS TO BE DONE
simid='ESF_medres'


%ALTERNATIVELY WE MAY WANT TO READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
fprintf('Reading in source file...\n');
ID='~/zettergmdata/simulations/ESF_eq/'


%READ IN THE SIMULATION INFORMATION
[ymd0,UTsec0,tdur,dtout,flagoutput,mloc]=readconfig([ID,'/inputs/config.ini']);
xgin=readgrid([ID,'/inputs/']);
direc=ID;


%FIND THE DATE OF THE frame that we want to extract.
%[ymdend,UTsecend]=dateinc(tdur,ymd0,UTsec0);
ymdend=[2016,3,3];
UTsecend=4500;


%LOAD THE FRAME
[ne,mlatsrc,mlonsrc,xgin,v1,Ti,Te,J1,v2,v3,J2,J3,filename,Phitop,ns,vs1,Ts]=loadframe(direc,ymdend,UTsecend,flagoutput,mloc,xgin);
lsp=size(ns,4);


%DO THE INTERPOLATION
if (lx3~=1)
  fprintf('Starting interp3''s...\n');
  [X2,X1]=meshgrid(xgin.x2(3:end-2),xgin.x1(3:end-2));
  [X2i,X1i]=meshgrid(xg.x2(3:end-2),xg.x1(3:end-2)); 
   for isp=1:lsp
    ix3=floor(xgin.lx(3)/2);

    tmpvar=interp2(X2,X1,squeeze(ns(:,:,ix3,isp)),X2i,X1i);
    inds=find(isnan(tmpvar));
    tmpvar(inds)=1e0;

    nsi(:,:,:,isp)=repmat(tmpvar,[1 1 lx3]);

    tmpvar=interp2(X2,X1,squeeze(vs1(:,:,ix3,isp)),X2i,X1i);
    tmpvar(inds)=0e0;

    vs1i(:,:,:,isp)=repmat(tmpvar,[1 1 lx3]);

    tmpvar=interp2(X2,X1,squeeze(Ts(:,:,ix3,isp)),X2i,X1i);
    tmpvar(inds)=100e0;

    Tsi(:,:,:,isp)=repmat(tmpvar,[1 1 lx3]);
  end
%{
  [X2,X1,X3]=meshgrid(xgin.x2(3:end-2),xgin.x1(3:end-2),xgin.x3(3:end-2));
  [X2i,X1i,X3i]=meshgrid(xg.x2(3:end-2),xg.x1(3:end-2),xg.x3(3:end-2)); 
  for isp=1:lsp
    tmpvar=interp3(X2,X1,X3,ns(:,:,:,isp),X2i,X1i,X3i);
    inds=find(isnan(tmpvar));
    tmpvar(inds)=1e0;
    nsi(:,:,:,isp)=tmpvar;
    tmpvar=interp3(X2,X1,X3,vs1(:,:,:,isp),X2i,X1i,X3i);
    tmpvar(inds)=0e0;
    vs1i(:,:,:,isp)=tmpvar;
    tmpvar=interp3(X2,X1,X3,Ts(:,:,:,isp),X2i,X1i,X3i);
    tmpvar(inds)=100e0;
    Tsi(:,:,:,isp)=tmpvar;
  end
%}
else
  fprintf('Starting interp2''s...\n');
  [X2,X1]=meshgrid(xgin.x2(3:end-2),xgin.x1(3:end-2));
  [X2i,X1i]=meshgrid(xg.x2(3:end-2),xg.x1(3:end-2));
  for isp=1:lsp
    tmpvar=interp2(X2,X1,squeeze(ns(:,:,:,isp)),X2i,X1i);
    inds=find(isnan(tmpvar));
    tmpvar(inds)=1e0;
    nsi(:,:,:,isp)=reshape(tmpvar,[lx1,lx2,1]);
    tmpvar=interp2(X2,X1,squeeze(vs1(:,:,:,isp)),X2i,X1i);
    tmpvar(inds)=0e0;
    vs1i(:,:,:,isp)=reshape(tmpvar,[lx1,lx2,1]);
    tmpvar=interp2(X2,X1,squeeze(Ts(:,:,:,isp)),X2i,X1i);
    tmpvar(inds)=100e0;
    Tsi(:,:,:,isp)=reshape(tmpvar,[lx1,lx2,1]);
  end
end


%WRITE OUT THE GRID
outdir=['~/zettergmdata/simulations/input/',simid,'/'];
writegrid(xg,outdir);    %just put it in pwd for now
dmy=[ymdend(3),ymdend(2),ymdend(1)];
writedata(dmy,UTsecend,nsi,vs1i,Tsi,outdir,simid);

