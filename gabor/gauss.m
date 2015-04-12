function [ y ] = gauss( x, sigma )
%gauss 1D-Gaussian function

y = (1 / (sigma * sqrt( 2 * pi ))) .* exp(- x.^2 ./ (2 * sigma)^2);

end

