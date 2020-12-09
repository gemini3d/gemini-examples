error("reference only: instead run:  model_setup('init/ARCS/config.nml')")

%PFISR-CENTERED GRID (CARTESIAN)
xdist=2950e3;    %eastward distance
%ydist=500e3;    %northward distance
%ydist=250e3;
ydist=400e3;
lxp=256;
lyp=288;
glat=65.8;
glon=207.7;
gridflag=0;
I=90;


%RUN THE GRID GENERATION CODE
if ~exist('xg', 'var')
  xg=makegrid_cart_3D(xdist,lxp,ydist,lyp,I,glat,glon);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%IDENTIFICATION FOR THE NEW SIMULATION THAT IS TO BE DONE
simid='ARCS'


%ALTERNATIVELY WE MAY WANT TO READ IN AN EXISTING OUTPUT FILE AND DO SOME INTERPOLATION ONTO A NEW GRID
fprintf('Reading in source file...\n');
ID=[gemini_root,'/../simulations/ARCS_eq/'];


%READ IN THE SIMULATION INFORMATION
[ymd0,UTsec0,tdur,dtout,flagoutput,mloc]=readconfig([ID,'/inputs']);
xgin=read.grid([ID,'/inputs/']);
direc=ID;


%FIND THE DATE OF THE END FRAEM OF THE SIMULATION (PRESUMABLY THIS WILL BE THE STARTING POITN FOR ANOTEHR)
[ymdend,UTsecend]=dateinc(tdur,ymd0,UTsec0);


%LOAD THE FRAME
[ne,mlatsrc,mlonsrc,xgin,v1,Ti,Te,J1,v2,v3,J2,J3,filename,Phitop,ns,vs1,Ts] = loadframe(get_frame_filename(direc,ymdend,UTsecend), flagoutput,mloc,xgin);
lsp=size(ns,4);

%DO THE INTERPOLATION
if (lx3~=1)
  fprintf('Starting interp3''s...\n');
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


%SCALE UP THE DENSITY, IF DESIRED (COULD CAUSE RINGING)
for isp=1:lsp-1
  nsi(:,:,:,isp)=4*nsi(:,:,:,isp);
end
nsi(:,:,:,end)=sum(nsi(:,:,:,1:lsp-1),4);


%WRITE OUT THE GRID
outdir=[gemini_root,'/../simulations/input/ARCS/'];
write.grid(xg,outdir);
dmy=[ymdend(3),ymdend(2),ymdend(1)];
write.data(dmy,UTsecend,nsi,vs1i,Tsi,outdir,simid);
