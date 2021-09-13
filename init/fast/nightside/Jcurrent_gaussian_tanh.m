function E = Jcurrent_gaussian_tanh(E, Nt, gridflag, flagdip)
% Set the top boundary shape (current density) and potential solve type
% flag.  Can be adjusted by user to achieve any desired shape.

arguments
  E (1,1) struct
  Nt (1,1) {mustBePositive,mustBeInteger}
  gridflag (1,1) {mustBePositive,mustBeInteger} = 0 %#ok<INUSA>
  flagdip (1,1) logical = false %#ok<INUSA>
end

Jpk=E.Jtarg;
%mlonsig=E.Efield_lonwidth;
%mlatsig=E.Efield_latwidth;
displace=10*E.mlatsig;
mlatctr=E.mlatmean+displace*tanh((E.MLON-E.mlonmean)/(2*E.mlonsig));    %changed so the arc is wider compared to its twisting
for it=1:Nt
  E.flagdirich(it)=0;
  E.Vminx1it(:,:,it)=zeros(E.llon,E.llat);
  if (it>2)
    E.Vmaxx1it(:,:,it)=Jpk.*exp(-(E.MLON-E.mlonmean).^2/2/E.mlonsig^2).*exp(-(E.MLAT-mlatctr-1.5*E.mlatsig).^2/2/E.mlatsig^2);
    E.Vmaxx1it(:,:,it)=E.Vmaxx1it(:,:,it)-Jpk.*exp(-(E.MLON-E.mlonmean).^2/2/E.mlonsig^2).*exp(-(E.MLAT-mlatctr+1.5*E.mlatsig).^2/2/E.mlatsig^2);
  else
    E.Vmaxx1it(:,:,it)=zeros(E.llon,E.llat);
  end %if
end %for

end % function
