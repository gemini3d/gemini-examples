function Q = precip_shape(pg, Qpeak, Qbackground)
%% makes a 2D Gaussian shape in Latitude, Longitude
arguments
  pg (1,1) struct
  Qpeak (1,1) {mustBeNonnegative,mustBeFinite}
  Qbackground (1,1) {mustBeNonnegative,mustBeFinite}
end

displace = 10 * pg.mlat_sigma;

mlatctr = pg.mlat_mean + displace * tanh((pg.MLON - pg.mlon_mean) / (2*pg.mlon_sigma) );
% changed so the arc is wider compared to its twisting

S = exp(-(pg.MLON - pg.mlon_mean).^2/2/pg.mlon_sigma^2) .* ...
    exp(-(pg.MLAT - mlatctr - 1.5*pg.mlat_sigma).^2/2/pg.mlat_sigma^2);
Q = Qpeak * S;

Q(Q < Qbackground) = Qbackground;

end % function
