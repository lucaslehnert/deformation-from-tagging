function [ g ] = gaborgausswin( sigma, L )
%gaborgausswin This function computes a Gaussian window that can be used
%with a Gabor transform.
%
% The length of the window L should be the same as the length of the
% signal. In the 2D case, one should use two windows, one for the
% horizontal and vertical transform. The horizontal and vertical window
% should have the same length/size of the image in the horizontal and
% vertical direction respectively. The Gaussian is normalized so that its
% L2-norm is 1.
%
%   [ g ] = gaborgausswin( sigma, L )
%
% Parameters:
%   sigma: Std. dev. of Gaussian
%   L: Length of the window
%
% Returns:
%   g: Window array
%

if nargin == 1
    sigma = 4.0;
end

x=1:L;
g = gauss(x-floor(L/2.0), sigma);
g = g ./ norm(g,2);
g = circshift(g',floor(L/2)+1)';

end

