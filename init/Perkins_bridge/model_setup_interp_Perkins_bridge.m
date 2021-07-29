run ~/Projects/mat_gemini-scripts/setup.m;

%MOORE, OK GRID (FULL)
p.dtheta=17.5;
p.dphi=20;
p.lp=350;
p.lq=256;
p.lphi=96;
p.altmin=80e3;
p.glat=39;
p.glon=262.51;
p.gridflag=0;

%MATLAB GRID GENERATION
if ~exist('xg', 'var')
  xg=gemscr.grid.makegrid_tilteddipole_varx2_3D(p.dtheta,p.dphi,p.lp,p.lq,p.lphi,p.altmin,p.glat,p.glon,p.gridflag);
end

% config and input file
p=gemini3d.read.config("./config.nml");    % eq2dist needs a populated config struct.
p.eq_dir='~/simulations/Perkins_eq.E0/';
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);

%INTERPOLATE ONTO THE NEW GRID
dat = gemini3d.model.eq2dist(p, xg);
lsp=size(dat.ns,4);

%FORCE A LONGITUDINAL CONSTANCY TO THE PARAMETERS (SINCE USING PERIODIC DOMAIN)
nsislice=dat.ns(:,:,floor(xg.lx(3)/2),:);
Tsislice=dat.Ts(:,:,floor(xg.lx(3)/2),:);
vs1islice=dat.vs1(:,:,floor(xg.lx(3)/2),:);
for ix3=1:xg.lx(3)
  nsi(:,:,ix3,:)=nsislice;
  Tsi(:,:,ix3,:)=Tsislice;
  vs1i(:,:,ix3,:)=vs1islice;
end
nsi=max(nsi,1e7);
nsi(:,:,:,7)=sum(nsi(:,:,:,1:6),4);
dint = struct("ns", nsi, "Ts", Tsi, "vs1", vs1i, "time", dat.time);

%WRITE OUT THE RESULTS TO A NEW FILE
p.outdir= '~/simulations/Perkins_bridge_eq';
gemini3d.write.grid(p,xg)
gemini3d.write.state(p.outdir, dint)
system(['cp config.nml ',p.outdir,'/inputs/']);
