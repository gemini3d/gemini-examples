%% Grid parameters, PFISR launch location for ISINGASS
mlonctr=259.0423;    %to be consistent with the rocket data from Rob C.
mlatctr=66.7615;
thetactr=pi/2-mlatctr*pi/180;
phictr=mlonctr*pi/180;

[pgrid.glat,pgrid.glon]= gemini3d.geomag2geog(thetactr,phictr);
%pgrid.xdist=270e3;    %eastward distance, trim to deal with clayton input
%pgrid.ydist=145e3;    %northward distance, trim to deal with clayton input
pgrid.xdist=250e3;    %eastward distance, trim to deal with tucker input
pgrid.ydist=125e3;    %northward distance, trim to deal with tucker input
pgrid.lxp=128;
pgrid.lyp=128;
pgrid.gridflag=0;
pgrid.gridflag=0;
pgrid.Bincl=90;
pgrid.alt_min=80e3;
pgrid.alt_max=975e3;
pgrid.alt_scale=[10e3, 8e3, 500e3, 150e3];    %parameters setting the nonuniform structure of the grid


%% RUN THE GRID GENERATION CODE
if (~exist('xg','var'))
  xg= gemini3d.grid.cart3d(pgrid);
end
lx1=xg.lx(1); lx2=xg.lx(2); lx3=xg.lx(3);


%% Interpolate data to desired grid resolution
pfile.file_format = 'raw';
pfile.eq_dir='../../../simulations/isinglass_eq/';
pfile.simdir='~/simulations/input/isinglass_clayton_flight/';
[nsi,vs1i,Tsi]= gemini3d.model.eq2dist(pfile,xg);
