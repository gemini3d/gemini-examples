
%MOORE, OK GRID (FULL)
dtheta=25;
dphi=35;
lp=125;
lq=200;    %will be ignored if using nonunifrom x2
lphi=96;
altmin=80e3;
glat=39;
glon=262.51;
gridflag=0;


%MATLAB GRID GENERATION
%xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
xg=gemini3d.grid.makegrid_tilteddipole_varx2_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
UT=19.75;
dmy=[18,5,2013];
activ=[124.6,138.5,6.1];


%USE OLD CODE FROM MATLAB MODEL
nmf=5e11;
nme=2e11;
[ns,Ts,vsx1]=gemini3d.model.eqICs(xg,UT,dmy,activ,nmf,nme);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
outdir = [gemini_root, filesep, '../simulations/input/Perkins_eq/'];
simlabel='Perkins_eq';
gemini3d.write.grid(xg,outdir);
time=UT*3600;   %doesn't matter for input files
gemini3d.write.data(dmy,time,ns,vsx1,Ts,outdir,simlabel);
