%READ IN THE SIMULATION INFORMATION
ID=[gemini_root,'/../simulations/input/GDI_periodic_round/']
xg= gemini3d.read.grid(ID);


%LOAD THE FRAME OF THE SIMULATION THAT WE WANT TO PERTURB
direc=ID;
filebase='GDI_periodic_round';
filename=[filebase,'_ICs.dat'];
[ne,v1,Ti,Te,ns,Ts,vs1,simdate]= gemini3d.vis.loadframe3Dcurvnoelec(direc,filename);
lsp=size(ns,4);



%%GDI EXAMPLE (PERIODIC, ROUND-SHAPED)
sigr=20d3;
meanr=0d0;

scalefact=5;      %density scaling
patchinc=8;

for isp=1:lsp
  for ix3=1:xg.lx(3)
    for ix2=1:xg.lx(2)
      amplitude=rand(xg.lx(1),1,1);
      amplitude=0.1*amplitude;
      nsperturb(:,ix2,ix3,isp)=ns(:,ix2,ix3,isp)+...                                                 %original data
                patchinc*ns(:,ix2,ix3,isp).*exp(-1d0*(sqrt(xg.x2(2+ix2).^2+xg.x3(2+ix3).^2)-meanr).^18/2d0/sigr.^18);        %patch, note offset in the x2 index!!!!

      if (ix2>10 & ix2<xg.lx(2)-10 & ix3>10 & ix3<xg.lx(3)-10)                                                              %noise should be added only away from the edges of the model
        nsperturb(:,ix2,ix3,isp)=nsperturb(:,ix2,ix3,isp)+amplitude.*ns(:,ix2,ix3,isp);
      end                                    %noise
      nsperturb(:,ix2,ix3,isp)=scalefact*nsperturb(:,ix2,ix3,isp);
    end
  end
end
nsperturb=max(nsperturb,1e4);


%WRITE OUT THE RESULTS TO A NEW FILE
outdir=ID;
dmy=[simdate(3),simdate(2),simdate(1)];
UTsec=simdate(4)*3600;
gemini3d.write.data(dmy,UTsec,nsperturb,vs1,Ts,outdir,[filebase,'_perturb']);
