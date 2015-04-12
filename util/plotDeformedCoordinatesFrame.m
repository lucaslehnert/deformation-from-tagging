function [  ] = plotDeformedCoordinatesFrame( T, im, offset, scale, ...
    axisRange, mask )
%plotDeformedCoordinatesFrame
%
%   T     tensor field
%   im    image
%   mask  Mask used for tensor plot
%
if nargin < 3
    offset = 5;
end
if nargin < 4
    scale = 1.0;
end
if nargin < 6
    mask = ones(size(im));
end

% calculate coordinate vectors
xAxis = zeros( size(T,1), size(T,2), 2 );
yAxis = zeros( size(T,1), size(T,2), 2 );
xAxisMin = zeros( size(T,1), size(T,2), 2 );
yAxisMin = zeros( size(T,1), size(T,2), 2 );

for i = 1:size(T,1)
    for j = 1:size(T,2)

        Tij = reshape(T(i,j,:,:), 2, 2);
        xAxis(i,j,:) = Tij * [ 1; 0];
        yAxis(i,j,:) = Tij * [ 0; 1];
        xAxisMin(i,j,:) = Tij * [ -1;  0];
        yAxisMin(i,j,:) = Tij * [  0; -1];

        xAxis(i,j,:) = xAxis(i,j,:) ./ norm(reshape(xAxis(i,j,:), 2,1));
        yAxis(i,j,:) = yAxis(i,j,:) ./ norm(reshape(yAxis(i,j,:), 2,1));
        xAxisMin(i,j,:) = xAxisMin(i,j,:) ./ norm(reshape(xAxisMin(i,j,:), 2,1));
        yAxisMin(i,j,:) = yAxisMin(i,j,:) ./ norm(reshape(yAxisMin(i,j,:), 2,1));

    end
end

% subsample all matrices
xxAxisSub = xAxis( 1:offset:size(T,1), 1:offset:size(T,2), 1 );
xyAxisSub = xAxis( 1:offset:size(T,1), 1:offset:size(T,2), 2 );
yxAxisSub = yAxis( 1:offset:size(T,1), 1:offset:size(T,2), 1 );
yyAxisSub = yAxis( 1:offset:size(T,1), 1:offset:size(T,2), 2 );
xxAxisMinSub = xAxisMin( 1:offset:size(T,1), 1:offset:size(T,2), 1 );
xyAxisMinSub = xAxisMin( 1:offset:size(T,1), 1:offset:size(T,2), 2 );
yxAxisMinSub = yAxisMin( 1:offset:size(T,1), 1:offset:size(T,2), 1 );
yyAxisMinSub = yAxisMin( 1:offset:size(T,1), 1:offset:size(T,2), 2 );

maskSub = mask( 1:offset:size(T,1), 1:offset:size(T,2) );
[ x, y ] = meshgrid( 1:offset:size(T,1), 1:offset:size(T,2) );        
ind = find( maskSub );

% draw plot
imRGB = zeros( size(im, 1), size(im, 2), 3);
imRGB(:,:,1) = im;
imRGB(:,:,2) = im;
imRGB(:,:,3) = im;
imshow(imRGB);
set(gca, 'YTick', []);
set(gca, 'XTick', []);
% xColor = [ 0   255 255 ];
% yColor = [ 255 255   0 ];
hold on 
quiver(x(ind), y(ind), xxAxisSub(ind), xyAxisSub(ind), ...
    scale, '.c', 'linewidth',2);
hold on
quiver(x(ind), y(ind), yxAxisSub(ind), yyAxisSub(ind), ...
    scale, '.y', 'linewidth',2);
hold on 
quiver(x(ind), y(ind), xxAxisMinSub(ind), xyAxisMinSub(ind), ...
    scale, '.c', 'linewidth',2);
hold on
quiver(x(ind), y(ind), yxAxisMinSub(ind), yyAxisMinSub(ind), ...
    scale, '.y', 'linewidth',2);

if nargin >= 5
    axis([axisRange(3), axisRange(4), axisRange(1), axisRange(2)]);
end
hold off

% set(gcf,'Units','normal');
% set(gca,'Position',[.002 .05 .85 .9]);
set(findall(gcf,'type','text'),'fontSize',14,'fontWeight','bold');

end

