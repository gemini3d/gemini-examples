clear all
close all
plotflag=1;


%% Where to put the output files for GEMINI
outdir='~/simulations/input/fields_isinglass_clayton5_tucker/';
system(['mkdir ',outdir]);


%% Load Tucker's fits for electric field
inputdir='~/Dropbox/common/mypapers/ISINGLASS/paper2_finally/';
%load([inputdir,'tucker_reconstructions.mat']);
load([inputdir,'tucker_reconstructions_reordered.mat']);
Xgeomag=permute(xout,[3,1,2]);                    %permute so that x is column index
Ygeomag=permute(yout,[3,1,2]);
Exgeomagdat=permute(uE,[3,2,1]);                  %why are these ordered differently!!!
Eygeomagdat=permute(vE,[3,2,1]);


%% Trim dataset to exclude boundary artifacts from Tucker's fits
ledge=5;    %number of edge points to trim off
Xgeomag=Xgeomag(:,ledge:end-ledge,ledge:end-ledge);
Ygeomag=Ygeomag(:,ledge:end-ledge,ledge:end-ledge);
Exgeomagdat=Exgeomagdat(:,ledge:end-ledge,ledge:end-ledge);
Eygeomagdat=Eygeomagdat(:,ledge:end-ledge,ledge:end-ledge);
[lt,llon,llat]=size(Eygeomagdat);


%% Convert geomag input to geographic
Ygeo=zeros(lt,llon,llat);
Xgeo=zeros(lt,llon,llat);
for it=1:lt
    Xgeomagtmp=squeeze(Xgeomag(1,:,:));    %really need the grid to not change with time, appears not to
    Ygeomagtmp=squeeze(Ygeomag(1,:,:));
    [Ygeo(it,:,:),Xgeo(it,:,:)]=geomag2geog(pi/2-Ygeomagtmp*pi/180,Xgeomagtmp*pi/180);
end %for


%AFAIK previous code's purpose is to put the data into the arrays Xgeo
%(glon) dimensions time,glon,glat; Ygeo(glat) dimensions same;
%Exgeomagdat,Eygeomagdat dimensions same, geomagnetic directions.  


%% Time information
day = 2*ones(lt,1);
month = 3*ones(lt,1);
year = 2017*ones(lt,1);
UThrs = outt(1:lt);      %may not include full time range???
UThrs = UThrs(:);
expdate=cat(2,year,month,day,UThrs,zeros(lt,1),zeros(lt,1));    %create a date vector for this dataset
t=datenum(expdate);


%% Call a function to do the interpolations and output
griddir='~/simulations/input/isinglass_clayton_flight/';    %have the prep code read the grid out of the input file
Efield2input(t,Xgeo,Ygeo,Exgeomagdat,Eygeomagdat,griddir,outdir);


%% Visualize input data
if (plotflag)
    figure;
    for it=1:lt
        xnow=xout(:,1,1);
        ynow=yout(1,:,1);
        uEnow=uflow(:,:,it);
        vEnow=vflow(:,:,it);
        subplot(121);
        imagesc(xnow',ynow',uEnow')
        axis xy;
        caxis([-0.05,0.05])
        colorbar('Location','SouthOutside');
        title(sprintf('Eastward, frame %d',it))
        subplot(122);
        imagesc(xnow',ynow',vEnow')
        axis xy;
        caxis([-0.05,0.05])      
        colorbar('Location','SouthOutside');
        title(sprintf('Northward, frame %d',it))
        framenum=num2str(it);
        while (numel(framenum)<2)
            framenum=['0',framenum];
        end %while
        print('-dpng',['~/Downloads/Tucker/',framenum,'.png'])
    end %for
end %if

