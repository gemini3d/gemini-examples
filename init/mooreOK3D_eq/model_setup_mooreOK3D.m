%MOORE, OK GRID (FULL), INTERHEMISPHERIC
dtheta=25;
dphi=35;
lp=125;
lq=425;
lphi=40;
altmin=80e3;
glat=39;
glon=262.51;
%gridflag=0;
gridflag=1;


%MATLAB GRID GENERATION
%xg=makegrid_tilteddipole_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
xg= gemini3d.grid.makegrid_tilteddipole_varx2_3D(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);
%xg=makegrid_tilteddipole_varx2_oneside_3D_eq(dtheta,dphi,lp,lq,lphi,altmin,glat,glon,gridflag);


%GENERATE SOME INITIAL CONDITIONS FOR A PARTICULAR EVENT - moore OK in this case
UT=19.75;
time = datetime([2013,5,18, UT]);
activ=[124.6,138.5,6.1];


%USE OLD CODE FROM MATLAB MODEL
nmf=5e11;
nme=2e11;
[ns,Ts,vsx1]= gemini3d.model.eqICs(xg,time,activ,nmf,nme);    %note that this actually calls msis_matlab - should be rewritten to include the neutral module form the fortran code!!!


%WRITE THE GRID AND INITIAL CONDITIONS
outdir = fullfile(gemini_root, '../simulations/input/mooreOK3D_eq/');

gemin3d.write.grid(xg,outdir);

gemini3d.write.state(outdir,time,ns,vsx1,Ts);
