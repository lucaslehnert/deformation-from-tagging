function [  ] = plotTensorCoord( ...
    T, imStack, imMask, offset, scale, axisRange, maskImage, coordcolor, colorrange )
%plotTensorCoord This function plots a tensor field by showing how it
%deformes a coordinate system.
%
% plotTensorCoord( T )
% plotTensorCoord( T, imStack )
% plotTensorCoord( T, imStack, imMask )
% plotTensorCoord( T, imStack, imMask, offset )
% plotTensorCoord( T, imStack, imMask, offset, scale )
% plotTensorCoord( T, imStack, imMask, offset, scale, axisRange )
% plotTensorCoord( T, imStack, imMask, offset, scale, axisRange, maskImage )
% plotTensorCoord( T, imStack, imMask, offset, scale, axisRange, maskImage, coordcolor, colorrange )
%
% Parameters:
%   T:          Tensor field indexed with (i,j,m,n,k) where (i,j) are pixel
%               coordinates, (m,n) are indices for the tensor entries (must 
%               be a 2x2 tensor), and k is an index ranging over the image 
%               stack.
%   imStack:    Image stack inxed with (i,j,k). If [] no image us used.
%   imMask:     Mask used for plotting the tensor field, indexed with
%               (i,j,k).
%   offset:     Spacing between the coordinate frames that are visualized.
%               Default value is 5, if [] is given default value is used.
%   scale:      Scale of the coordinate frames. Default is 1, if [] is
%               given default is used.
%   axisRange:  Range of the image that should be showed. Default is to 
%               show the whole image, if [] is given default is used.
%   maskImage:  If true also the imStack will be masked based on the
%               segmentation mask. False is the default value.
%   coordcolor: Colors for the coordinates that should be used. For
%               example, can be ['c','y'] for x-axis and y-axis.
%   colorrange: Range of the color map, default is to use the max and min
%               or the whole imStack.
%   

if nargin == 1
    imStack = [];
    imMask = [];
    offset = 5;
    scale = 1;
    axisRange = [ 1, size(imStack, 1), 1, size(imStack, 2) ];
    maskImage = false;
    coordcolor = ['c','y'];
    colorrange = [ min( imStack(:) ), max( imStack(:) ) ];
elseif nargin == 2
    imMask = [];
    offset = 5;
    scale = 1;
    axisRange = [ 1, size(imStack, 1), 1, size(imStack, 2) ];
    maskImage = false;
    coordcolor = ['c','y'];
    colorrange = [ min( imStack(:) ), max( imStack(:) ) ];
elseif nargin == 3
    offset = 5;
    scale = 1;
    axisRange = [ 1, size(imStack, 1), 1, size(imStack, 2) ];
    maskImage = false;
    coordcolor = ['c','y'];
    colorrange = [ min( imStack(:) ), max( imStack(:) ) ];
elseif nargin == 4
    scale = 1;
    axisRange = [ 1, size(imStack, 1), 1, size(imStack, 2) ];
    maskImage = false;
    coordcolor = ['c','y'];
    colorrange = [ min( imStack(:) ), max( imStack(:) ) ];
elseif nargin == 5 
    axisRange = [ 1, size(imStack, 1), 1, size(imStack, 2) ];
    maskImage = false;
    coordcolor = ['c','y'];
    colorrange = [ min( imStack(:) ), max( imStack(:) ) ];
elseif nargin == 6
    maskImage = false;
    coordcolor = ['c','y'];
    colorrange = [ min( imStack(:) ), max( imStack(:) ) ];
elseif nargin == 7
    coordcolor = ['c','y'];
    colorrange = [ min( imStack(:) ), max( imStack(:) ) ];
elseif nargin == 8
    colorrange = [ min( imStack(:) ), max( imStack(:) ) ];    
end

t = 1;
figure('KeyPressFcn', @updatePlot);
set(gcf, 'Renderer','OpenGL');
set(gcf,'numbertitle','off','name',strcat('Frame ',num2str(t)));

plotDeformedCoordinatesAtTime( T, imStack, imMask, t );
    
    function updatePlot( ~, event )
        if event.Character == 'w'
            t = t + 1;
        end;
        if event.Character == 'q'
            t = t - 1;
        end;
        t = mod(t - 1, size(T, 5)) + 1;
        set(gcf,'numbertitle','off','name',strcat('Frame ',num2str(t)));
        plotDeformedCoordinatesAtTime( T, imStack, imMask, t );
    end

    function plotDeformedCoordinatesAtTime( T, imStack, imMask, t )
        Tt = T(:,:,:,:,t);
        if size( imStack, 1 ) ~= 0
            imt = imStack(:,:,t);
        end
        if size( imMask, 1 ) ~= 0
            mask = imMask(:,:,t);
        end
        
        % calculate coordinate vectors
        xAxis = zeros( size(Tt,1), size(Tt,2), 2 );
        yAxis = zeros( size(Tt,1), size(Tt,2), 2 );
        xAxisMin = zeros( size(Tt,1), size(Tt,2), 2 );
        yAxisMin = zeros( size(Tt,1), size(Tt,2), 2 );

        for i = 1:size(Tt,1)
            for j = 1:size(Tt,2)

                Tij = reshape(Tt(i,j,:,:), 2, 2);
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
        xxAxisSub = xAxis( 1:offset:size(Tt,1), 1:offset:size(Tt,2), 1 );
        xyAxisSub = xAxis( 1:offset:size(Tt,1), 1:offset:size(Tt,2), 2 );
        yxAxisSub = yAxis( 1:offset:size(Tt,1), 1:offset:size(Tt,2), 1 );
        yyAxisSub = yAxis( 1:offset:size(Tt,1), 1:offset:size(Tt,2), 2 );
        xxAxisMinSub = xAxisMin( 1:offset:size(Tt,1), 1:offset:size(Tt,2), 1 );
        xyAxisMinSub = xAxisMin( 1:offset:size(Tt,1), 1:offset:size(Tt,2), 2 );
        yxAxisMinSub = yAxisMin( 1:offset:size(Tt,1), 1:offset:size(Tt,2), 1 );
        yyAxisMinSub = yAxisMin( 1:offset:size(Tt,1), 1:offset:size(Tt,2), 2 );
        
        maskSub = mask( 1:offset:size(Tt,1), 1:offset:size(Tt,2) );
        [ x, y ] = meshgrid( 1:offset:size(Tt,1), 1:offset:size(Tt,2) );        
        ind = find( maskSub );
                
        % draw plot
        if maskImage
            h = imagesc( imt );
            set( h, 'AlphaData', mask);
            colormap(jet);
            colorbar('FontSize', 20);
            caxis( colorrange );
            axis equal
        else
            imshow(imt);
        end
        set(gca, 'YTick', []);
        set(gca, 'XTick', []);
        xColor = [ 0   255 255 ];
        yColor = [ 255 255   0 ];
        hold on 
        quiver(x(ind), y(ind), xxAxisSub(ind), xyAxisSub(ind), ...
            scale, strcat('.', coordcolor(1)));
        hold on
        quiver(x(ind), y(ind), yxAxisSub(ind), yyAxisSub(ind), ...
            scale, strcat('.', coordcolor(2)));
        hold on 
        quiver(x(ind), y(ind), xxAxisMinSub(ind), xyAxisMinSub(ind), ...
            scale, strcat('.', coordcolor(1)));
        hold on
        quiver(x(ind), y(ind), yxAxisMinSub(ind), yyAxisMinSub(ind), ...
            scale, strcat('.', coordcolor(2)));
        
        axis([axisRange(3), axisRange(4), axisRange(1), axisRange(2)]);
        hold off
        
        set(gcf,'Units','normal')
        set(gca,'Position',[.002 .05 .85 .9])
        set(findall(gcf,'type','text'),'fontSize',14,'fontWeight','bold')

    end

end


