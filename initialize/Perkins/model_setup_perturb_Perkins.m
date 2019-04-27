cwd = fileparts(mfilename('fullpath'));
gemini_root = [cwd, filesep, '../../../GEMINI'];
addpath([gemini_root, filesep, 'script_utils'])
addpath([gemini_root, filesep, 'setup/gridgen'])
addpath([gemini_root, filesep, 'setup/'])
addpath([gemini_root, filesep, 'vis'])
geminiscripts_root = [cwd, filesep, '../../../GEMINI-scripts'];
addpath([geminiscripts_root,filesep,'setup/gridgen']);


%MOORE, OK GRID (FULL)
dtheta=20;
dphi=27.5;
lp=350;
lq=384;
lphi=192;
altmin=80e3;
glat=39;
glon=262.51;
gridflag=0;


%MATLAB GRID GENERATION
%{
if (~exist('xg'))
  %xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
  xg=makegrid_tilteddipole_varx2_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end
%}
eqdir=[gemini_root,'/../simulations/Perkins_bridge/'];
if (~exist('xg'))
    xg=readgrid([eqdir,'inputs/']);
    lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);
end



%INTERPOLATE ONTO THE NEW GRID
%eqdir=[geminiscripts_root,filesep,'../simulations/Perkins_bridge/'];
simID='Perkins';
[nsi,vs1i,Tsi,xg,ns,vs1,Ts]=eq2dist(eqdir,simID,xg);


%FORCE A LONGITUDINAL CONSTANCY TO THE PARAMETERS (SINCE USING PERIODIC DOMAIN)
nsislice=nsi(:,:,floor(xg.lx(3)/2),:);
Tsislice=Tsi(:,:,floor(xg.lx(3)/2),:);
vs1islice=vs1i(:,:,floor(xg.lx(3)/2),:);
for ix3=1:xg.lx(3)
  nsi(:,:,ix3,:)=nsislice;
  Tsi(:,:,ix3,:)=Tsislice;
  vs1i(:,:,ix3,:)=vs1islice;
end


%%NOW ADD SOME NOISE TO SEED PERKINS INSTABILITY, ADD DIFFERENT NOISE AT EACH POINT
%nsi=nsi+0.1*nsi.*randn(size(nsi));
%nsi=max(nsi,1e8);

%%NOISE; ADD AS AN ADJUSTMENT TO DENSITY PROFILE
for isp=1:lsp
  for ix3=1:lx3
    for ix2=1:lx2
      ns(:,ix2,ix3,isp)=nsi(:,ix2,ix3,isp)+0.1*nsi(:,ix2,ix3,isp).*randn(1);
      nsi=max(nsi,1e8);
    end
  end
end
nsi(:,:,:,7)=sum(nsi(:,:,:,1:6),4);


%WRITE OUT THE RESULTS TO A NEW FILE
outdir=[gemini_root,'/../simulations/input/Perkins'];
writegrid(xg,outdir);
%dmy=[simdate(3),simdate(2),simdate(1)];
dmy=[2,2,2002];     %isn't used by GEMINI anyway...
%UTsec=simdate(4)*3600;
UTsec=1;
writedata(dmy,UTsec,nsi,vs1i,Tsi,outdir,[simID,'_perturb']);
