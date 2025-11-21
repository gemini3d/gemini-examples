function E = fac_said(E, Nt, gridflag, flagdip)
% Set the top boundary shape (current density) and potential solve type flag
arguments
  E (1,1) struct
  Nt (1,1) {mustBePositive, mustBeInteger}
  gridflag (1,1) {mustBeInteger}
  flagdip (1,1) logical = false %#ok<INUSA>
end

%if E.llon == 1 || E.llat == 1
%  error("Efield:fac_said is for 3D sims only")
%end

%% nonuniform in longitude
%shapelon = exp(-((E.MLON - E.mlonmean).^2) / 2 / E.mlonsig^2);

% Interpret widths as quarter-wavelengths
lambda=4*E.mlatsig;
wavenum=2*pi/lambda;

%% nonuniform in latitude
%shapelat = exp(-((E.MLAT - E.mlatmean + 1.5 * E.mlatsig).^2) / 2 / E.mlatsig^2) ...
%             - exp(-((E.MLAT - E.mlatmean - 1.5 * E.mlatsig).^2) / 2 / E.mlatsig^2);
% shapelat=-sin(wavenum*(E.MLAT - E.mlatmean));
% inds=find(abs(E.MLAT - E.mlatmean)>lambda/2);
% shapelat(inds)=0.0;
shapelat=-cos(wavenum*(E.MLAT - E.mlatmean));
inds=find(abs(E.MLAT - E.mlatmean)>lambda*3/4);
shapelat(inds)=0.0;
inds=find(abs(E.MLAT - E.mlatmean)>lambda*1/4);
shapelat(inds)=0.5*shapelat(inds);

for i = 3:Nt
    %could have different boundary types for different times if the user wanted...
    E.flagdirich(i)=0;

    if gridflag==1
        k = "Vminx1it";
    else
        k = "Vmaxx1it";
    end

    %E.(k)(:,:,i) = E.Jtarg .* shapelon .* shapelat;
    E.(k)(:,:,i) = E.Jtarg .* shapelat;

end
