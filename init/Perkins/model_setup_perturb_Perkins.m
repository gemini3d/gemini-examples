
%MOORE, OK GRID (FULL)
dtheta=20;
dphi=10;
lp=350;
%lq=384;
lq=256;
%lphi=192;
lphi=96;
altmin=80e3;
glat=39;
glon=262.51;
gridflag=0;


%MATLAB GRID GENERATION

if ~exist('xg', 'var')
  %xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
  xg= gemini3d.grid.makegrid_tilteddipole_varx2_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
end

eqdir=['~/simulations/Perkins_bridge_vn/'];

lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%INTERPOLATE ONTO THE NEW GRID
%eqdir=[geminiscripts_root,filesep,'../simulations/Perkins_bridge/'];
simID='Perkins';
[nsi,vs1i,Tsi,xgin,ns,vs1,Ts]= gemini3d.model.eq2dist(eqdir,simID,xg, file_format);
lsp=size(nsi,4);


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

%{
  for ix3=1:lx3
    for ix2=5:lx2
      noise=randn(1);
      for isp=1:lsp
        nsi(:,ix2,ix3,isp)=nsi(:,ix2,ix3,isp)+0.001*nsi(:,ix2,ix3,isp).*noise;
      end
    end
  end
%}
nsi=max(nsi,1e7);
nsi(:,:,:,7)=sum(nsi(:,:,:,1:6),4);


%WRITE OUT THE RESULTS TO A NEW FILE
outdir= fullfile(gemini_root,'../simulations/input/Perkins');

gemini3d.write.grid(xg,outdir);
time = datetime(2002,2,2);     %isn't used by GEMINI anyway...

gemini3d.write.state(outdir, time,nsi,vs1i,Tsi);
