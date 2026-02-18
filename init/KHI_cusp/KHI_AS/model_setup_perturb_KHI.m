%READ IN THE SIMULATION INFORMATION
ID=[gemini_root,'/../simulations/input/KHI_Andres/'];
xg= gemini3d.read.grid(ID);
x1=xg.x1(3:end-2); x2=xg.x2(3:end-2); x3=xg.x3(3:end-2);
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
direc=ID;
filebase='KHI_Andres';
filename=[filebase,'_ICs.dat'];
dat = gemini3d.read.frame3Dcurvnoelec(fullfile(direc,filename));
lsp=size(ns,4);


%Game the variables to get us a correct density value...
%v0=350;
%vn=350;
%voffset=100;
%v0=650;
%vn=650;
%voffset=100;

sigx2=1000e0;
%sigx2=5e3;
meanx3=0e0;
meanx2=0e0;


ne0=1e11;
ne1=4e11;
nsperturb=zeros(size(ns));
for isp=1:1
  for ix2=1:xg.lx(2)
    amplitude=rand(xg.lx(1),1,xg.lx(3));
    amplitude=0.025*amplitude;
    for ix3=1:xg.lx(3)
      amplitude=rand(xg.lx(1),1,1);
      amplitude=0.025*amplitude;
      nsperturb(:,ix2,ix3,isp)=ns(:,ix2,ix3,isp).*(ne0/max(ns(:,ix2,ix3,isp)))+ns(:,ix2,ix3,isp).*(ne1/max(ns(:,ix2,ix3,isp))).* ...
                          (1/2+1/2.*tanh((xg.x2(2+ix2))/sigx2));
      nsperturb(:,ix2,ix3,isp)=nsperturb(:,ix2,ix3,isp)+amplitude.*ns(:,ix2,ix3,isp);
    end
  end
end
nsperturb(:,:,:,2:6)=ns(:,:,:,2:6);


%NOW WE NEED TO WIPE OUT THE E-REGION TO GET RID OF DAMPING
x1ref=150e3;     %where to start tapering down the density
dx1=10e3;
taper=1/2+1/2*tanh((x1-x1ref)/dx1);
for isp=1:lsp
   for ix3=1:lx3
       for ix2=1:lx2
           nsperturb(:,ix2,ix3,isp)=1e8+nsperturb(:,ix2,ix3,isp).*taper;
       end
   end
end
nsperturb(:,:,:,lsp)=sum(nsperturb(:,:,:,1:6),4);

dat.ns = nsperturb;
%WRITE OUT THE RESULTS TO A NEW FILE
outdir=ID;
gemini3d.write.state(outdir,dat)
