function E = fac_said(E, Nt, gridflag, flagdip)
% Set the top boundary shape (current density) and potential solve type flag
arguments
  E (1,1) struct
  Nt (1,1) {mustBePositive, mustBeInteger}
  gridflag (1,1) {mustBeInteger}
  flagdip (1,1) logical = false %#ok<INUSA>
end

if E.llon == 1 || E.llat == 1
  error("Efield:fac_said is for 3D sims only")
end

%% nonuniform in longitude
shapelon = exp(-((E.MLON - E.mlonmean).^2) / 2 / E.mlonsig^2);

%% nonuniform in latitude
shapelat = 0.7*exp(-((E.MLAT - E.mlatmean + 1.5 * E.mlatsig).^2) / 2 / E.mlatsig^2) ...
             - exp(-((E.MLAT - E.mlatmean - 1.5 * E.mlatsig).^2) / 2 / E.mlatsig^2);

for i = 3:Nt
%could have different boundary types for different times if the user wanted...
E.flagdirich(i)=0;

if gridflag==1
  k = "Vminx1it";
else
  k = "Vmaxx1it";
end

E.(k)(:,:,i) = E.Jtarg .* shapelon .* shapelat;

end
