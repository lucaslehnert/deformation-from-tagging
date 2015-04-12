function [  ] = plotScalarFieldFrame( scalarField, im, scalarRange, axisRange, mask )
%plotScalarFieldFrame Plot a scalar field on top of a frame.
%
%
if nargin < 5
    mask = ones(size(im));
end

if nargin < 3
    scalarRange = [ min(scalarField(:)) ; max(scalarField(:)) ];
end

imRGB = zeros( size(im, 1), size(im, 2), 3);
imRGB(:,:,1) = im;
imRGB(:,:,2) = im;
imRGB(:,:,3) = im;

imh = imshow( imRGB );
set( imh, 'AlphaData', 0.3 );
set( gca, 'visible', 'off' );
hold on

h = imagesc( scalarField );
colormap(jet(256));
colorbar
set(gca,'children',flipud(get(gca,'children')))
set( h, 'AlphaData', 1 .* mask  );
caxis( scalarRange );
if nargin >=5 
    axis([axisRange(3), axisRange(4), axisRange(1), axisRange(2)]);
end

set(gca, 'YTick', []);
set(gca, 'XTick', []);

axis square

hold off

end
