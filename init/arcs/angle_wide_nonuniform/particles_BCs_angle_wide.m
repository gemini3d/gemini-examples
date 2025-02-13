function particles_BCs(p, xg)
% create particle precipitation
arguments
  p (1,1) struct
  xg (1,1) struct
end

outdir = p.prec_dir;
% gemini3d.fileio.makedir(outdir)
stdlib.fileio.makedir(outdir)

%% CREATE PRECIPITATION CHARACTERISTICS data
% number of grid cells.
% This will be interpolated to grid, so 100x100 is arbitrary
precip = struct('llon', 4096, 'llat', 4096);
if xg.lx(2) == 1    % cartesian
  precip.llon=1;
elseif xg.lx(3) == 1
  precip.llat=1;
end

%% TIME VARIABLE (seconds FROM SIMULATION BEGINNING)
% dtprec is set in config.nml
precip.times = p.times(1):seconds(p.dtprec):p.times(end);
Nt = length(precip.times);

%% CREATE PRECIPITATION INPUT DATA
% Qit: energy flux [mW m^-2]
% E0it: characteristic energy [eV]
precip.Qit = zeros(precip.llon, precip.llat, Nt);
precip.E0it = zeros(precip.llon,precip.llat, Nt);

% did user specify on/off time? if not, assume always on.
if isfield(p, 'precip_startsec')
  i_on = round(p.precip_startsec / p.dtprec) + 1;
else
  i_on = 1;
end

if isfield(p, 'precip_endsec')
  i_off = round(min(p.tdur, p.precip_endsec) / p.dtprec);
else
  i_off = Nt;
end

if ~isfield(p, 'Qprecip')
  warning('You should specify "Qprecip, Qprecip_background, E0precip" in "setup" namelist of config.nml. Defaulting to Q=1, E0=1000')
  Qprecip = 1;
  Qprecip_bg = 0.01;
  E0precip = 1000;
else
  Qprecip = p.Qprecip;
  Qprecip_bg = p.Qprecip_background;
  E0precip = p.E0precip;
  E0precip_bg = p.E0precip_background; % Pralay --> E0 doesn't drop below background
end

% precip = gemini3d.setup.precip_grid(xg, p, precip);
precip = gemini3d.particles.grid(xg, p);

%% User-defined precipitation shape
lt=Nt;
precip.Qit=zeros(precip.llon,precip.llat,lt);
precip.E0it=zeros(precip.llon,precip.llat,lt);

mlonsig=precip.mlon_sigma;
mlatsig=precip.mlat_sigma;

displace=10*mlatsig;
mlatctr=precip.mlat_mean+displace*tanh((precip.MLON-precip.mlon_mean)/(2*mlonsig)); %changed so the arc is wider compared to its twisting


Qpk=Qprecip;
E0pk=E0precip;
QBG=Qprecip_bg;
E0BG = E0precip_bg;
% vely=-0.025;    %degrees mlat per second
% velx=0;
ii = 1;

Filter = "off";
%% Band pass filter 
if Filter == "on"
    N = 4;                    % Order of the filter
    dx1 = xg.x2(2)-xg.x2(1);  % spacing between two grid points at the beginning of the grid
    dx2 = xg.x2((end/2)+1) - xg.x2((end/2)); % spacing between two grid points at the central grid
    fs1 = 1/dx1;                    % sampling frequency
    fs2 = 1/dx2;                    % sampling frequency
    fc1 = ((fs1/10)*fs1);          % Cutoff frequency
    fc2 = (fs2/10)/(fs2/7);          % Cutoff frequency
    %   fc2 = 0.9;
    fc = [fc1 fc2];
    [zero,pole,gain] = butter(N,fc,'bandpass');
    %% high pass filter
    %   dx = xg.x2((end/2)+1) - xg.x2((end/2));
    %   fs = 1/dx;
    %   fc = (fs/10)/(fs/7);
    %   [zero,pole,gain] = butter(N,fc,'high');  % Zero,pole and gain for transfer function
    %% low pass filter
    %   dx = xg.x2((end/2)+1) - xg.x2((end/2));
    %   fs = 1/dx;
    %   fc = (fs/10)/(fs/7);
    %   [zero,pole,gain] = butter(N,fc,'low');  % Zero,pole and gain for transfer function
    %% Transfer function
    [num,den] = zp2tf(zero,pole,gain);
end
  
Spiral_arc = "no";
  %% Spiral arc
  if Spiral_arc == "yes"
      lx=1024; ly=1024;
      x=linspace(-10,10,lx);
      %     x = linspace(219,289,lx);
      %     y = linspace(59,70,ly);
      y=linspace(-10,10,ly);
      [X,Y]=meshgrid(x,y);
      ltt=100;
      t=linspace(0,5,ltt);
      wt = (t/2)*pi;
      % r = (0.75*cos(2*pi*t/max(t)) + 0.5)  * 5;
      r = (0.5*cos(2.25*t/max(t)) + 0.5)  * 5;
      c = @(r,th) [r.*cos(th); r.*sin(th)];
      curve = c(r,wt)+1;
      
      x0 = curve(1,:);
      y0 = curve(2,:);
      % y0=r.^(1/4).*cos(wt);
      % x0=r.^(1/4).*sin(wt);
      % y0=t.^(1/4).*cos(t);
      % x0=t.^(1/4).*sin(t);
      sigma=0.4;
      % sigma=5;
      
      
      % shapefn = exp(-(X-x0).^2/2/sigma^2).*exp(-(Y-y0).^2/2/sigma^2);
      
      % figure;
      % plot(x0,y0);
      
      shapefn=zeros(lx,ly);
   end
   
  Noise = "PL";  % AWGN/Randn/Sinusoidal - noise additions
%   Filter = "on";        % Band Pass Filter On/Off
  shape = "Regular";      % Regular/Spiral - Arc shape
  vx = -600;  %m/s
  vy = -600;
  motion = "none"; %E-W, N-S
for it=1:lt
    if shape == "Regular"
%         precip.mlon_mean =  precip.mlon_mean+vx*second(precip.times(it))*0.011*1e-3;   %1km = 0.011 degrees lon
%         mlatctr =  mlatctr+vy*second(precip.times(it))*0.009*1e-3;                      %1km = 0.009 degrees lat
        xdist = 2*max(xg.x2(:));
        ydist = 2*max(xg.x3(:));
        dMLON = precip.MLON(end)-precip.MLON(1);
        dMLAT = precip.MLAT(end)-precip.MLAT(1);
        dlon = vx * dMLON/xdist * (second(precip.times(it)) + 60 * (minute(precip.times(it)) - 30));
        dlat = vy * dMLAT/ydist * (second(precip.times(it)) + 60 * (minute(precip.times(it)) - 30));
%         dlon = (vx*(length(precip.Qit)/xdist))*second(precip.times(it))* (dMLON/length(precip.Qit));
%         dlat = (vy*(length(precip.Qit)/ydist))*second(precip.times(it)) * (dMLAT/length(precip.Qit));
%         precip.mlon_mean =  precip.mlon_mean + dlon;   %1km = 0.011 degrees lon
%         mlatctr =  mlatctr + dlat;                   %1km = 0.009 degrees lat

           if motion == "E-W"
               mlong = precip.MLON + dlon;
               precip.mlon_mean = mean(mlong(:));
               mlatctr_m = mlatctr;
           elseif motion == "N-S"
               mlatctr_m = mlatctr + dlat;
           else
               mlatctr_m = mlatctr;
           end
           
%         shapefn = exp(-(precip.MLON-precip.mlon_mean).^8/2/mlonsig^8).*exp(-(precip.MLAT-mlatctr_m-1.5*mlatsig).^2/2/mlatsig^2);
        shapefn = exp(-(precip.MLON-precip.mlon_mean).^16/2/mlonsig^16).*exp(-(precip.MLAT-mlatctr_m).^16/2/mlatsig^16); % centering the structure
    elseif shape == "Spiral"
        for ix=1:lx
            for iy=1:ly
                shapefn(ix,iy)=0;
                for itt=1:ltt
                    %              mlatctr=precip.mlat_mean+vely*time+displace*tanh((precip.MLON-precip.mlon_mean)/(mlonsig));
                    shapefn(ix,iy)=shapefn(ix,iy) + exp(-(X(ix,iy)-x0(itt)).^2/2/sigma).*...
                        exp(-(Y(ix,iy)-y0(itt)).^2/2/sigma)*itt^(2);
                    
                    %             shapefn = exp(-(precip.MLON-precip.mlon_mean).^2/2/mlonsig^2).*exp(-(precip.MLAT-mlatctr-1.5*mlatsig).^2/2/mlatsig^2);
                    
                    %             F(ix,iy)=exp(-(X(ix,iy)).^2/2/sigma).*exp(-(Y(ix,iy)).^2/2/sigma);
                    
                end
            end
        end
        shapefn = shapefn/max(shapefn(:));
    end
    
    
%   time=it*p.dtprec*100;
%   
%   shapefn = exp(-(precip.MLON-precip.mlon_mean).^2/2/mlonsig^2).*exp(-(precip.MLAT-mlatctr-1.5*mlatsig).^2/2/mlatsig^2);
%   shapefn = shapefn + exp(-(X-x0).^2/2/sigma).*...
%                 exp(-(Y-y0).^2/2/sigma)*itt^(2);
  Qittmp=Qpk.*shapefn;  % Total energy flux
  E0ittmp = E0pk.*shapefn;  % Characteristic energy
%   precip.E0it(:,:,it)=E0pk;   %*ones(llon,llat);     %eV
  inds=Qittmp<QBG;        %define a background flux (enforces a floor for production rates)
  Qittmp(inds)=QBG;
  
  indE = E0ittmp<E0BG;
  E0ittmp(indE) = E0BG;
  % Noise added -- Added by Pralay -- 11 Feb 2021
  %% White Gaussian noise
  %shapefn_noise_measured=awgn(Qittmp,50,'measured'); %% white Gaussian noise
  if Noise == "none"
      precip.Qit(:,:,it)= Qittmp;
      precip.E0it(:,:,it)= E0ittmp ;
  elseif Noise == "PL"
      
      %       if mod(it-1,10) == 0
      N = length(shapefn);
      
      l0x = 20*10^3;          % Outer scale in x (across the arc)
      l0y = 2*10^3;          % Outer scale in y (tangential)
      %       k0 = 2*pi./l0;      % Outer scale wavenumber
      k0x = 2*pi./l0x;      % Outer scale wavenumber in x-direction
      k0y = 2*pi./l0y;      % Outer scale wavenumber in y-direction
      
      dx = (max(xg.x2)-min(xg.x2))/N; % inner scale in x-direction
      dy = (max(xg.x3)-min(xg.x3))/N; % inner scale in y-direction
      
      dkx = 2*pi./dx; % inner scale wavenumber in x-direction
      dky = 2*pi./dy; % inner scale wavenumber  in y-direction
      
      kx = ((-N/2:N/2-1)*(2*pi/dx))/N;             % wavenumber axis in x-direction
      ky = ((-N/2:N/2-1)*(2*pi/dy))/N;             % wavenumber axis in y-direction
      
%       kx = ((-N/2:N/2-1)*(2*pi/k0x))/N;             % wavenumber axis in x-direction
%       ky = ((-N/2:N/2-1)*(2*pi/k0y))/N;             % wavenumber axis in y-direction
      
%       kx = linspace(k0x,dkx,N);             % wavenumber axis in x-direction
%       ky = linspace(k0y,dky,N);             % wavenumber axis in y-direction
      
      
      
      %       kx = linspace(2*pi./xg.x2(1),2*pi./xg.x2(end),N);
      %       ky = linspace(2*pi./xg.x3(1),2*pi./xg.x3(end),N);
      
      [Ky,Kx]=meshgrid(ky,kx);
      Ky = flip(Ky);
      K = sqrt(Kx.^2+Ky.^2);
      
      yff2d=zeros(size(K));
      
      for ifreq=1:N
          for kfreq = 1:N
              %               if ( abs(K(ifreq,kfreq)) < k0 )
              %                   yff2d(ifreq,kfreq)= 0.398*k0.^(-5/3) * 0.022;
              %               if ( abs(Kx(ifreq,kfreq))< k0x && abs(Ky(ifreq,kfreq)) < k0y )
              %                   yff2d(ifreq,kfreq)= 0.398*k0x.^(-5/3) *k0y.^(-3)* 0.022;
              % %                     yff2d(ifreq,kfreq)= 10^10;
              %               elseif abs(Kx(ifreq,kfreq))< k0x
              %                   yff2d(ifreq,kfreq)= 0.398*k0x.^(-5/3) * abs(Ky(ifreq,kfreq)).^(-3) * 0.022;
              %               elseif abs(Ky(ifreq,kfreq))< k0y
              %                   yff2d(ifreq,kfreq)= 0.398*abs(Kx(ifreq,kfreq)).^(-5/3) * k0y.^(-3) * 0.022;
              %               else
              % %                   yff2d(ifreq,kfreq)= 0.398*abs(Kx(ifreq,kfreq)).^(-5/3) * abs(Ky(ifreq,kfreq)).^(-3) * 0.022; % using approx Powerlaw referring from Dr. Nishimura slides and scaling [R^2 km] to [(mW/m2)^2 m] by factor 210 R = 1 mW/m2
              %                   %         yff2d(ifreq,kfreq) = (1./(1+(K(ifreq,kfreq)/k0).^(-5/3)));
              %               end %if
              if ( ((Kx(ifreq,kfreq).^2/k0x.^2) + (Ky(ifreq,kfreq).^2/k0y.^2)) < 1 )
                  yff2d(ifreq,kfreq)= 0.398*0.0047;   % 1R = 1/210 mW/m2; 10^6 is taken from Dr. Nishimura's PSD plot as reference power at which the spectrum is constant
              else
                  if ( (Kx(ifreq,kfreq)) && (Ky(ifreq,kfreq)) < (2*pi/0.75e3)) % scales greater than 1km
                      yff2d(ifreq,kfreq)= 0.398*(sqrt((Kx(ifreq,kfreq).^2/k0x.^2) + (Ky(ifreq,kfreq).^2/k0y.^2))).^(-5/3)* 0.0047; % slope for wavenumbers equal/greater than 1km scales (large scales)
                  else
                      yff2d(ifreq,kfreq)= 0.398*(sqrt((Kx(ifreq,kfreq).^2/k0x.^2) + (Ky(ifreq,kfreq).^2/k0y.^2))).^(-3)* 0.0047;  % slope for wavenumbers less than 1km scales (small scales)
                  end
              end %if
             
          end
      end
      
      phase = 2*pi*rand(size(yff2d));
      yf2d=sqrt(yff2d).*exp(1i*phase);

      
      % if mod(N,2)==0
      %     for i=1:N  %% even
      %         yf2d(i,floor(N/2)+2:floor(N))=fliplr(conj(yf2d(i,2:floor(N/2))));
      %         yf2d(i,floor(N/2)+1)=real(yf2d(i,floor(N/2)+1));
      %         yf2d(i,1)=real(yf2d(i,1));
      %     end
      % else
      %     for i=1:N  %% odd
      %         yf2d(i,floor(N/2)+2:floor(N))=fliplr(conj(yf2d(i,1:floor(N/2))));
      %         yf2d(i,floor(N/2)+1)=real(yf2d(i,floor(N/2)+1));
      %     end
      % end
      
      % MZ - enforce known (Hermitian) symmetry - viz. the 1st and 3rd quadrants
      % of the fft2 of a real-valued signal are complex conjugates.  Likewise for
      % the 2nd and 4th quadrant.  For now we assume that we have an even number
      % of samples so that yf2d(floor((N/2))+1,floor(N/2))+1) is the DC
      % component.  We also assume numel(kx)=numel(ky).
      %       iDC=floor(N/2)+1;
      %       yf2d_q13=yf2d(iDC:end,iDC:end);
      %       yf2d_q24=yf2d(1:iDC-1,iDC:end);
      %       yf2d(1:iDC-1,1:iDC-1)=fliplr(flipud(conj(yf2d_q13)));
      %       yf2d(iDC:end,1:iDC-1)=fliplr(flipud(conj(yf2d_q24)));
      
      % MZ - complete the ifft to get spatial signal (noise)
      y2d=ifft2(ifftshift(yf2d),'symmetric');    % why tf does this need symmetric????
      
      % MZ - check results
      yf2d_check=fftshift(fft2(y2d));
      
      %       figure;
      %       subplot(131);
      %       pcolor(kx,ky,log10(yf2d'.*conj(yf2d'))),shading interp;
      %       title("original spectrum");
      % %       caxis([-5 0]);
      %       axis equal;
      %       axis xy
      %       colorbar;
      %
      %       subplot(132);
      %       pcolor(kx,ky,y2d'),shading interp;
      %       title("Noise spectrum");
      %       axis equal;
      %       axis xy
      %       colorbar;
      %
      %       subplot(133);
      %       pcolor(kx,ky,log10(yf2d_check'.*conj(yf2d_check'))),shading interp;
      %       title("retained original spectrum");
      % %       caxis([-5 0]);
      %       axis equal;
      %       axis xy
      %       colorbar;
      
      %       y2dM = abs(y2d);
      %       y2dM = y2dM./max(y2dM(:));
      
       % Apply the shapefn window to the spatial signal (noise)
       
      
      y2dM_no_w = y2d./max(abs((y2d(:)))); %zero-mean random noise
      
      noise_amp = 1.25*Qpk;
%       noise_amp = (3/3)*Qpk;
      arc_in_no_w = noise_amp.*y2dM_no_w;
      
      
      
      % Apply the shapefn window to the spatial signal (noise)
      arc_in_W = y2d.*shapefn;
      
      y2dM = arc_in_W./max(abs((arc_in_W(:)))); %zero-mean random noise
      
      noise_amp = 1.25*Qpk;
%       noise_amp = (3/3)*Qpk;
      arc_in = noise_amp.*y2dM;
      
      Windowed_Noise = arc_in;
      
      % Windowed noise
      % Gaussian Window
      %       GW = fspecial('gaussian',size(y2dM),length(y2dM)/12);
      %       GW = abs(GW);
      %       GW = GW./max(GW(:));
      %
      %       % Apply the Gaussian window to the noise
      %       Windowed_Noise = y2dM.*shapefn;
      %       arc = Qittmp;
      %       ind_nonQ = arc==1;
      %       arc(ind_nonQ) = 0;
      %       % arc_in = arc + (y2d);
      %       % arc_in = (arc.*arc_in);
      % %       smoothedData = movmean(Windowed_Noise,10);
      % %       arc_in = arc.*(smoothedData);
      %       arc_in_W = arc.*(Windowed_Noise);
      %
      %       inds_noise=Windowed_Noise<QBG;
      %       Windowed_Noise(inds_noise)=QBG;
      
      %       noise_amp_E = 1/3*E0pk;
      %       arc_E = E0ittmp>1e3;
      %       arc_in_E = (arc_E + (noise_amp_E*y2dM));
      %       arc_in_E = (arc_E.*arc_in_E);
      
  elseif Noise == "mixed"
      N = 2^10;
      x = linspace(0,3,N);
      y = x;
      fs = 1./x(2)-x(1);
      kx = linspace(-fs/2,fs/2,N);
      ky = kx;
      
      [KY,KX] = meshgrid(kx,ky);
      [Y,X] = meshgrid(x,y);
      
      % arc background ditribution
      
      t=linspace(0,1,N);
      Fs = 1/(t(2)-t(1));         % sampling frequency
      df = Fs/length(t);
      f = linspace(-Fs/2,Fs/2,N);
      [Yy,Xx] = meshgrid(f,f);
      sigmaf=(max(Xx)-min(Xx))/10;
      yff_g=zeros(size(Xx));
      for i=1:N
          for k = 1:N
              yff_g(i,k)= exp(-Xx(i,k).^2/10/sigmaf(k)^2);
          end
      end
      
      yf_g=sqrt(yff_g).*exp(2*pi*1i*rand(size(yff_g)));
      
      for i=1:N
          yf_g(i,floor(N/2)+2:floor(N))=fliplr(conj(yf_g(i,2:floor(N/2))));
          yf_g(i,floor(N/2)+1)=real(yf_g(i,floor(N/2)+1));
          yf_g(i,1)=real(yf_g(i,1));
      end
      
      y_g=zeros(size(yf_g));
      for i = 1:N
          y_g(i,:)=ifft(ifftshift(yf_g(i,:)));
      end
      
      ind = y_g<0;
      y_g(ind) = 0;
      y_g = 10*y_g;
      
      % arc distribution
      yff2d=zeros(size(X));
      
      vth = 1;
      kappa = 3;
      alpha = 5/3;
      
      dist = 'Maxwell';
      
      switch dist
          
          case 'Kappa'
              for ifreq=1:N
                  for kfreq = 1:N
                      yff2d(ifreq,kfreq)= (X(ifreq,kfreq).^2).*(1+(X(ifreq,kfreq).^2/kappa.*vth^2)).^-(kappa+1);
                  end
              end
              
          case 'Maxwell'
              for ifreq=1:N
                  for kfreq = 1:N
                      yff2d(ifreq,kfreq)= (X(ifreq,kfreq).^2).*exp(-X(ifreq,kfreq).^2/(2*vth^2));
                  end
              end
              
          case 'Powerlaw'
              for ifreq=1:N
                  for kfreq = 1:N
                      yff2d(ifreq,kfreq)= (KX(ifreq,kfreq).^2).^(-alpha);
                  end
              end
      end
      
      yf2d=sqrt(yff2d).*exp(2*pi*1i*rand(size(yff2d)));
      
      for i=1:N
          yf2d(i,floor(N/2)+2:floor(N))=fliplr(conj(yf2d(i,2:floor(N/2))));
          yf2d(i,floor(N/2)+1)=real(yf2d(i,floor(N/2)+1));
          yf2d(i,1)=real(yf2d(i,1));
      end
      
      y2d=zeros(size(yf2d));
      for i = 1:N
          y2d(i,:)=ifft(ifftshift(yf2d(i,:)));
      end
      
      ind = y2d<0;
      y2d(ind) = 0;
      
      % creating gaussian background (outside arc)
      w_arc = Qittmp==1;
      arc_bg = w_arc + (2*y_g);
      arc_bg = (w_arc.*arc_bg);
      
      arc = Qittmp>1;
      arc_in = arc + (500*y2d);
      arc_in = (arc.*arc_in);
      
      arc_full = arc_bg+arc_in;
      
      w_arc_E = E0ittmp==1e3;
      arc_bg_E = 1000 + (w_arc_E + (100*y_g));
      arc_bg_E = (w_arc_E.*arc_bg_E);
      
      arc_E = E0ittmp>1e3;
      arc_in_E = 1000 + (arc_E + (15000*y2d));
      arc_in_E = (arc_E.*arc_in_E);
      
      arc_full_E = arc_bg_E+arc_in_E;
      
  elseif Noise == "Rand_noise"
      %% Rand Noise -- 18 May 2021
      if it == ii
          ii = ii+4;
          Noise_amp = 1*Qpk/6;
          Q_noise_new = Noise_amp*randn(size(Qittmp)).*shapefn;
          ind_rand = Q_noise_new<QBG;
          Q_noise_new(ind_rand) = QBG;
          
          % spatially varying E0
          Noise_ampE = 1*E0pk/6;
          E0_noise_new = Noise_ampE*randn(size(E0ittmp)).*shapefn;
          indE_rand = E0_noise_new<E0BG;
          E0_noise_new(indE_rand) = E0BG;
      end
  elseif Noise == "Sinusoidal"
      %% Sinusoidal
      shapefn_noise1 = 1.1*sin(shapefn);
      Qittmp_noise1=Qpk_noise.*shapefn_noise1;
      inds_noise1=Qittmp_noise1<QBG;
      Qittmp_noise1(inds_noise1)=QBG;
  end
      if Filter == "on"
          %% Filtered white noise
          %Qittmp_noise_filt = filter(num,den,Qittmp_noise,[],length(Qittmp_noise));
          Qittmp_noise_filt = filter(num,den,arc_in,[],length(arc_in));
          inds_noise_filt=Qittmp_noise_filt<QBG;
          Qittmp_noise_filt(inds_noise_filt)=QBG;
          
          %       E0ittmp_noise_filt = filter(num,den,E0_noise_new,[],length(E0_noise_new));
          %       inds_noise_filt_E0=E0ittmp_noise_filt<E0BG;
          %       E0ittmp_noise_filt(inds_noise_filt_E0)=E0BG;
      end
      %% Total precipitation
      %   if it <= 13
      %   precip.Qit(:,:,it)=Qittmp; % Add Noise to original precipatation structure.
      %   precip.E0it(:,:,it)=E0ittmp;
      %   elseif it > 13 && it <= 25
      %       precip.Qit(:,:,it)=Qittmp + Q_noise_new;
      %       precip.E0it(:,:,it)=E0ittmp + E0_noise_new;
      %   elseif it > 25
      %       precip.Qit(:,:,it)=Qittmp;
      %       precip.E0it(:,:,it)=E0ittmp;
      %   end
      
      if  Noise == "none"
          precip.Qit(:,:,it)= Qittmp;
      else
          precip.Qit(:,:,it)= max(Qittmp + arc_in,QBG);
      end
      precip.E0it(:,:,it)= E0ittmp;
end

%% diagnostic plots
if Noise == 'PL'
    figure;
    subplot(231);
    x = linspace(xg.x2(1),xg.x2(end),length(Windowed_Noise));
    y = linspace(xg.x3(1),xg.x3(end),length(Windowed_Noise));
    pcolor(x,y,Windowed_Noise'),shading interp;
    title("spatial noise (windowed) before Q added");
    xlabel('xdist [m]','FontSize',14,'Color','black');
    ylabel('ydist [m]','FontSize',14,'Color','black');
    axis xy;
    axis equal
    colorbar;
    x_value = length(Windowed_Noise)/2 + 1;
    line('XData', [x_value, x_value], 'YData', [min(y),max(y)], 'Color', 'red', 'LineStyle', '--','LineWidth', 1);
    
    subplot(232)
    %       plot(Windowed_Noise)
    %       title("Windowed Noise");
    %       axis xy;
    %       colorbar;
    plot(y,Windowed_Noise(end/2+1,:)')
    title("Windowed Noise");
    axis xy;
    ylabel('Intensity [mW/m^2]','FontSize',14,'Color','black');
    
    arc_PSD = precip.Qit(:,:,end);
    F = fftshift(fft2(arc_PSD));             % 2D Fourier transform
    dkx = min(diff(kx));
    dky = min(diff(ky));
    Fs_kx = 1 / (2*dkx);                     % sampling freq for kx
    Fs_ky = 1 / (2*dky);                     % sampling freq for ky
    
    Pxx = (1/(Fs_kx*N)) * abs(F).^2;              % PSD in spatial spectral domain in kx direction
    Pyy = (1/(Fs_ky*N)) * abs(F).^2;              % PSD in spatial spectral domain in kx direction
    P = sqrt(Pxx.^2 +Pyy.^2);
    % figure, semilogx(kx, 10*log10(P(:,end/2)));
    subplot(236)
    %       loglog(K(:,end/2+1),P(:,end/2+1),'k','LineWidth',1);
    loglog(K(end/2+1,:),P(end/2+1,:)','k','LineWidth',1);
    %       hold on
    %       loglog(K(end/2+1,:),P(end/2+1,:),'r','LineWidth',1);
    xlabel('k [1/m]','FontSize',14,'Color','black');
    ylabel('Power [mW/m^2]^2 m','FontSize',14,'Color','black');
    title("Power Spectral Density")
    xlim([1e-04 1e-02])
    grid on;
    
    %       subplot(248);
    %       loglog(K(:,end/2+1).*10^3,P(:,end/2+1).*45,'k','LineWidth',1);
    %       xlabel('k [1/km]','FontSize',14,'Color','black');
    %       ylabel('Power [R^2 km]','FontSize',14,'Color','black');
    %       title("Power Spectral Density")
    %       grid on;
    
    noise_PSD = Windowed_Noise;
    F_n = fftshift(fft2(noise_PSD));
    Pxx_n = (1/(Fs_kx*N)) * abs(F_n).^2;
    Pyy_n = (1/(Fs_ky*N)) * abs(F_n).^2;
    P_n = sqrt(Pxx_n.^2 + Pyy_n.^2);
    subplot(233)
    %       loglog(K(:,end/2+1),P_n(:,end/2+1),'k','LineWidth',1);
    loglog(K(end/2+1,:),P_n(end/2+1,:)','k','LineWidth',1);
    %       hold on
    %       loglog(K(end/2+1,:),P_n(end/2+1,:),'r','LineWidth',1);
    xlabel('k [1/m]','FontSize',14,'Color','black');
    %       xlabel('k [1/m]','FontSize',14,'Color','black');
    %       ylabel('Power [m(W/m^2)^2 m]','FontSize',14,'Color','black');
    ylabel('Power [mW/m^2]^2 m','FontSize',14,'Color','black');
    title("Power Spectral Density")
    xlim([1e-04 1e-02])
    grid on;
    
    %       subplot(244);
    %       loglog(K(:,end/2+1).*10^3,P_n(:,end/2+1).*45,'k','LineWidth',1);
    %       xlabel('k [1/km]','FontSize',14,'Color','black');
    %       ylabel('Power [R^2 km]','FontSize',14,'Color','black');
    %       title("Power Spectral Density")
    %       grid on;
    
    subplot(234)
    pcolor(x,y,precip.Qit(:,:,end)'),shading interp;
    title("spatial noise with Q added");
    xlabel('xdist [m]','FontSize',14,'Color','black');
    ylabel('ydist [m]','FontSize',14,'Color','black');
    axis xy;
    axis equal
    colorbar;
    
    x_value = length(precip.Qit(:,:,end))/2 + 1;
    line('XData', [x_value, x_value], 'YData', [min(y),max(y)], 'Color', 'red', 'LineStyle', '--','LineWidth', 1);
    
    subplot(235)
    %       plot(precip.Qit(:,:,end))
    %       title("Noise added to arc");
    %       axis xy;
    %       colorbar;
    plot(y,precip.Qit(end/2+1,:,end)')
    title("Noise added to arc");
    axis xy;
    ylabel('Intensity [mW/m^2]','FontSize',14,'Color','black');
    %%   Y-cut
    figure;
    subplot(231);
    x = linspace(xg.x2(1),xg.x2(end),length(Windowed_Noise));
    y = linspace(xg.x3(1),xg.x3(end),length(Windowed_Noise));
    pcolor(x,y,Windowed_Noise'),shading interp;
    title("spatial noise (windowed) before Q added");
    xlabel('xdist [m]','FontSize',14,'Color','black');
    ylabel('ydist [m]','FontSize',14,'Color','black');
    axis xy;
    axis equal
    colorbar;
    y_value = length(Windowed_Noise)/2 + 1;
    line('XData', [min(x),max(x)], 'YData', [y_value, y_value], 'Color', 'red', 'LineStyle', '--','LineWidth', 1);
    
    subplot(232)
    %       plot(Windowed_Noise)
    %       title("Windowed Noise");
    %       axis xy;
    %       colorbar;
    plot(x,Windowed_Noise(:,end/2+1)')
    title("Windowed Noise");
    axis xy;
    ylabel('Intensity [mW/m^2]','FontSize',14,'Color','black');
    
    arc_PSD = precip.Qit(:,:,end);
    F = fftshift(fft2(arc_PSD));             % 2D Fourier transform
    dkx = min(diff(kx));
    dky = min(diff(ky));
    Fs_kx = 1 / (2*dkx);                     % sampling freq for kx
    Fs_ky = 1 / (2*dky);                     % sampling freq for ky
    
    Pxx = (1/(Fs_kx*N)) * abs(F).^2;              % PSD in spatial spectral domain in kx direction
    Pyy = (1/(Fs_ky*N)) * abs(F).^2;              % PSD in spatial spectral domain in kx direction
    P = sqrt(Pxx.^2 +Pyy.^2);
    % figure, semilogx(kx, 10*log10(P(:,end/2)));
    subplot(236)
    %       loglog(K(:,end/2+1),P(:,end/2+1),'k','LineWidth',1);
    loglog(K(:,end/2+1),P(:,end/2+1)','k','LineWidth',1);
    %       hold on
    %       loglog(K(end/2+1,:),P(end/2+1,:),'r','LineWidth',1);
    xlabel('k [1/m]','FontSize',14,'Color','black');
    ylabel('Power [mW/m^2]^2 m','FontSize',14,'Color','black');
    title("Power Spectral Density")
     xlim([1e-04 1e-02])
    grid on;
    
    %       subplot(248);
    %       loglog(K(:,end/2+1).*10^3,P(:,end/2+1).*45,'k','LineWidth',1);
    %       xlabel('k [1/km]','FontSize',14,'Color','black');
    %       ylabel('Power [R^2 km]','FontSize',14,'Color','black');
    %       title("Power Spectral Density")
    %       grid on;
    
    noise_PSD = Windowed_Noise;
    F_n = fftshift(fft2(noise_PSD));
    Pxx_n = (1/(Fs_kx*N)) * abs(F_n).^2;
    Pyy_n = (1/(Fs_ky*N)) * abs(F_n).^2;
    P_n = sqrt(Pxx_n.^2 + Pyy_n.^2);
    subplot(233)
    %       loglog(K(:,end/2+1),P_n(:,end/2+1),'k','LineWidth',1);
    loglog(K(:,end/2+1),P_n(:,end/2+1)','k','LineWidth',1);
    %       hold on
    %       loglog(K(end/2+1,:),P_n(end/2+1,:),'r','LineWidth',1);
    xlabel('k [1/m]','FontSize',14,'Color','black');
    %       xlabel('k [1/m]','FontSize',14,'Color','black');
    %       ylabel('Power [m(W/m^2)^2 m]','FontSize',14,'Color','black');
    ylabel('Power [mW/m^2]^2 m','FontSize',14,'Color','black');
    title("Power Spectral Density")
    xlim([1e-04 1e-02])
    grid on;
    
    %       subplot(244);
    %       loglog(K(:,end/2+1).*10^3,P_n(:,end/2+1).*45,'k','LineWidth',1);
    %       xlabel('k [1/km]','FontSize',14,'Color','black');
    %       ylabel('Power [R^2 km]','FontSize',14,'Color','black');
    %       title("Power Spectral Density")
    %       grid on;
    
    subplot(234)
    pcolor(x,y,precip.Qit(:,:,end)'),shading interp;
    title("spatial noise with Q added");
    xlabel('xdist [m]','FontSize',14,'Color','black');
    ylabel('ydist [m]','FontSize',14,'Color','black');
    axis xy;
    axis equal
    colorbar;
    
    y_value = length(precip.Qit(:,:,end))/2 + 1;  % Replace this with the desired row index for your horizontal line
    line('XData', [min(x),max(x)], 'YData', [y_value, y_value], 'Color', 'red', 'LineStyle', '--','LineWidth', 1);
    
    subplot(235)
    %       plot(precip.Qit(:,:,end))
    %       title("Noise added to arc");
    %       axis xy;
    %       colorbar;
    plot(x,precip.Qit(:,end/2+1,end)')
    title("Noise added to arc");
    axis xy;
    ylabel('Intensity [mW/m^2]','FontSize',14,'Color','black');
    
    figure;
    subplot(131);
    pcolor(kx,ky,log10(yf2d'.*conj(yf2d'))),shading interp;
    title("original spectrum");
    %       caxis([-5 0]);
    axis equal;
    colorbar;
    
    subplot(132);
    pcolor(x,y,y2d'),shading interp;
    title("Noise realization");
    axis equal;
    colorbar;
    
    subplot(133);
    pcolor(kx,ky,log10(yf2d_check'.*conj(yf2d_check'))),shading interp;
    title("retained original spectrum");
    %       caxis([-5 0]);
    axis equal;
    colorbar;
    %%
    
    figure;
    y_value = length(arc_in_no_w)/2 + 1;
    arc_PSD = precip.Qit(:,:,end);
    F = fftshift(fft2(arc_PSD));             % 2D Fourier transform
    dkx = min(diff(kx));
    dky = min(diff(ky));
    Fs_kx = 1 / (2*dkx);                     % sampling freq for kx
    Fs_ky = 1 / (2*dky);                     % sampling freq for ky
    
    Pxx = (1/(Fs_kx*N)) * abs(F).^2;              % PSD in spatial spectral domain in kx direction
    Pyy = (1/(Fs_ky*N)) * abs(F).^2;              % PSD in spatial spectral domain in kx direction
    P = sqrt(Pxx.^2 +Pyy.^2);
    %%
    noise_PSD = arc_in_no_w;
    F_n = fftshift(fft2(noise_PSD));
    Pxx_n = (1/(Fs_kx*N)) * abs(F_n).^2;
    Pyy_n = (1/(Fs_ky*N)) * abs(F_n).^2;
    P_n = sqrt(Pxx_n.^2 + Pyy_n.^2);
    
    subplot(231)
    pcolor(x,y,arc_in_no_w'),shading interp;
    title("spatial noise before Q added");
    xlabel('xdist [m]','FontSize',14,'Color','black');
    ylabel('ydist [m]','FontSize',14,'Color','black');
    axis xy;
    axis equal
    colorbar;
    line('XData', [min(x),max(x)], 'YData', [y_value, y_value], 'Color', 'red', 'LineStyle', '--','LineWidth', 1);
    
    subplot(233);
    pcolor(kx,ky,F_n'.*conj(F_n')),shading interp;
    title("spatial noise before Q added");
    xlabel('xdist [m]','FontSize',14,'Color','black');
    ylabel('ydist [m]','FontSize',14,'Color','black');
    axis xy;
    axis equal
    colorbar;
    subplot(232);
    %       loglog(K(:,end/2+1),P_n(:,end/2+1),'k','LineWidth',1);
    loglog(K(end/2+1,:),P_n(end/2+1,:)','k','LineWidth',1);
    %       hold on
    %       loglog(K(end/2+1,:),P_n(end/2+1,:),'r','LineWidth',1);
    xlabel('k [1/m]','FontSize',14,'Color','black');
    %       xlabel('k [1/m]','FontSize',14,'Color','black');
    %       ylabel('Power [m(W/m^2)^2 m]','FontSize',14,'Color','black');
    ylabel('Power [mW/m^2]^2 m','FontSize',14,'Color','black');
    title("Power Spectral Density")
    xlim([1e-04 1e-02])
    grid on;
    
     subplot(234)
    pcolor(x,y,precip.Qit(:,:,end)'),shading interp;
    title("spatial noise after Q added");
    xlabel('xdist [m]','FontSize',14,'Color','black');
    ylabel('ydist [m]','FontSize',14,'Color','black');
    axis xy;
    axis equal
    colorbar;
    line('XData', [min(x),max(x)], 'YData', [y_value, y_value], 'Color', 'red', 'LineStyle', '--','LineWidth', 1);
    
    subplot(235);
    %       loglog(K(:,end/2+1),P_n(:,end/2+1),'k','LineWidth',1);
    loglog(K(:,end/2+1),P(:,end/2+1)','k','LineWidth',1);
    %       hold on
    %       loglog(K(end/2+1,:),P_n(end/2+1,:),'r','LineWidth',1);
    xlabel('k [1/m]','FontSize',14,'Color','black');
    %       xlabel('k [1/m]','FontSize',14,'Color','black');
    %       ylabel('Power [m(W/m^2)^2 m]','FontSize',14,'Color','black');
    ylabel('Power [mW/m^2]^2 m','FontSize',14,'Color','black');
    title("Power Spectral Density")
    xlim([1e-04 1e-02])
    grid on;
    
    subplot(236);
    pcolor(kx,ky,F'.*conj(F')),shading interp;
    title("spatial noise before Q added");
    xlabel('xdist [m]','FontSize',14,'Color','black');
    ylabel('ydist [m]','FontSize',14,'Color','black');
    axis xy;
    axis equal
    colorbar;
    
    %%
    figure
%     x_value = length(Windowed_Noise)/2 + 1;
    arc_PSD = precip.Qit(:,:,end);
    F = fftshift(fft2(arc_PSD));             % 2D Fourier transform
    dkx = min(diff(kx));
    dky = min(diff(ky));
    Fs_kx = 1 / (2*dkx);                     % sampling freq for kx
    Fs_ky = 1 / (2*dky);                     % sampling freq for ky
    
    Pxx = (1/(Fs_kx*N)) * abs(F).^2;              % PSD in spatial spectral domain in kx direction
    Pyy = (1/(Fs_ky*N)) * abs(F).^2;              % PSD in spatial spectral domain in kx direction
    P = sqrt(Pxx.^2 +Pyy.^2);
    %%
    noise_PSD = arc_in_no_w;
    F_n = fftshift(fft2(noise_PSD));
    Pxx_n = (1/(Fs_kx*N)) * abs(F_n).^2;
    Pyy_n = (1/(Fs_ky*N)) * abs(F_n).^2;
    P_n = sqrt(Pxx_n.^2 + Pyy_n.^2);
    
    subplot(223)
    pcolor(x,y,precip.Qit(:,:,end)'),shading interp;
    title("spatial noise with Q added");
    xlabel('xdist [m]','FontSize',14,'Color','black');
    ylabel('ydist [m]','FontSize',14,'Color','black');
    axis xy;
    axis equal
    colorbar;
    
    x_value = length(precip.Qit(:,:,end))/2 + 1;
    line('XData', [x_value, x_value], 'YData', [min(y),max(y)], 'Color', 'red', 'LineStyle', '--','LineWidth', 1);
    
    subplot(224)
    loglog(K(end/2+1,:),P(end/2+1,:)','k','LineWidth',1);
    %       hold on
    %       loglog(K(end/2+1,:),P(end/2+1,:),'r','LineWidth',1);
    xlabel('k [1/m]','FontSize',14,'Color','black');
    ylabel('Power [mW/m^2]^2 m','FontSize',14,'Color','black');
    title("Power Spectral Density")
    xlim([1e-04 1e-02])
    grid on;
    
    subplot(222)
    loglog(K(end/2+1,:),P_n(end/2+1,:)','k','LineWidth',1);
    %       hold on
    %       loglog(K(end/2+1,:),P_n(end/2+1,:),'r','LineWidth',1);
    xlabel('k [1/m]','FontSize',14,'Color','black');
    %       xlabel('k [1/m]','FontSize',14,'Color','black');
    %       ylabel('Power [m(W/m^2)^2 m]','FontSize',14,'Color','black');
    ylabel('Power [mW/m^2]^2 m','FontSize',14,'Color','black');
    title("Power Spectral Density")
    xlim([1e-04 1e-02])
    grid on;
    
    subplot(221)
    pcolor(x,y,arc_in_no_w'),shading interp;
    title("spatial noise (windowed) before Q added");
    xlabel('xdist [m]','FontSize',14,'Color','black');
    ylabel('ydist [m]','FontSize',14,'Color','black');
    axis xy;
    axis equal
    colorbar;
    x_value = length(arc_in_no_w')/2 + 1;
    line('XData', [x_value, x_value], 'YData', [min(y),max(y)], 'Color', 'red', 'LineStyle', '--','LineWidth', 1);
    
end
        
%% Error checking
if any(~isfinite(precip.Qit)), error('particle_BCs:value_error', 'precipitation flux not finite'), end
if any(~isfinite(precip.E0it)), error('particle_BCs:value_error', 'E0 not finite'), end


%% CONVERT THE ENERGY TO EV
%E0it = max(E0it,0.100);
%E0it = E0it*1e3;

gemini3d.write.precip(precip, outdir, p.file_format)

end % function