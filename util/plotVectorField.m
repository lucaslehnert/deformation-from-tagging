function [  ] = plotVectorField( uv, im, offset, scale )
%plotVectorField This function plots a vector field.
%
% plotVectorField( uv, )
% plotVectorField( uv, im )
% plotVectorField( uv, im, offset )
% plotVectorField( uv, im, offset, scale )
%
% Parameters:
%   uv:     Vector field indexed with (i,j,x) with (i,j) being pixel
%           coordinates and x being the vector entry (1 or 2).
%           Alternatively can also show a vector field stack with indexing
%           (i,j,x,k), with k being the index ranging over the image
%           slices.
%   im:     Image or image stack with indexing (i,j) or (i,j,k) with (i,j)
%           being pixels and k being the index ranging over the image
%           stack. If this image stack is given, then the vector field will
%           be overlayed to it. If [] is given, the no image will be used.
%   offset: Offset between the different vectors that are shown. This is
%           used to downsample the vector field. The default value is 5. If
%           [] is given the default value is used.
%   scale:  Scaling of the vector field in the plot. The default value is 
%           1. If [] is given the default value is used.
%
% If a vector field stack or image stack is given then keys 'q' and 'w' can
% be used for scrolling. 
%
% Note: uv and im must have the same size for pixel coordinates and the
% same number of slices if an image stack is given (i.e. index i,j,k must 
% have the same range).
%

if nargin == 1
    im = [];
    offset = 5;
    scale = 1;
elseif nargin == 2
    offset = 5;
    scale = 1;
elseif nargin == 3
    scale = 1;
end
if size(offset, 1) == 0
    offset = 5;
end
if size(scale, 1) == 0
    scale = 1;
end

[ m, n, ~ ] = size(uv);
[ x, y ] = meshgrid( 1:offset:m, 1:offset:n );

if ndims(uv) == 3
    plotFlowFieldAtTime( uv, im );    
else
    t = 1;
    figure('KeyPressFcn', @updatePlot);
    set(gcf,'numbertitle','off','name',strcat('Frame ',num2str(t)));
    if size( im, 1 ) ~= 0
        plotFlowFieldAtTime( uv(:,:,:,t), im(:,:,t) );
    else
        plotFlowFieldAtTime( uv(:,:,:,t), [] );
    end
end

    function updatePlot( ~, event )
        if event.Character == 'w'
            t = t + 1;
        end;
        if event.Character == 'q'
            t = t - 1;
        end;
        t = mod(t - 1, size(uv, 4)) + 1;
        set(gcf,'numbertitle','off','name',strcat('Frame ',num2str(t)));
        if size( im, 1 ) ~= 0
            plotFlowFieldAtTime( uv(:,:,:,t), im(:,:,t) );
        else
            plotFlowFieldAtTime( uv(:,:,:,t), [] );
        end
    end

    function plotFlowFieldAtTime( uvt, imt )
        if size( imt, 1 ) ~= 0
            imshow(imt);
            hold on
        end
        quiver(x, y, uvt(1:offset:m,1:offset:n,1), ...
            uvt(1:offset:m,1:offset:n,2), scale, '.-');
        hold off
        
    end


end

