function [  ] = plotSegmentationMask( maskStack, imStack, axisRange )
%plotSegmentationMask This function plots the given segmentation mask.
%
% plotSegmentationMask( maskStack )
% plotSegmentationMask( maskStack, imStack )
% plotSegmentationMask( maskStack, imStack, axisRange )
% plotSegmentationMask( maskStack, [], axisRange )
%
% The maskStack (and the optional image stack) are indexed with (i,j,k),
% with (i,j) being pixel coordinates and k being the index ranging over the
% image stack.
%
% Parameters:
%   maskStack:  Segmentation mask of type double.
%   imStack:    Image stack on which the segmentation mask is overlayed.
%               Also of type double.
%   axisRange:  Axis range in which to show the plot, indexing is [ imin, 
%               imax, jmin, jmax ].
%

if nargin == 1
    imStack = [];
    axisRange = [ 1, size(maskStack, 1), 1, size(maskStack, 2) ];
elseif nargin == 2
    axisRange = [ 1, size(maskStack, 1), 1, size(maskStack, 2) ];
end

t = 1;
figure('KeyPressFcn', @updatePlot);
set(gcf,'numbertitle','off','name',strcat('Frame ',num2str(t)));
if size(imStack, 1) ~= 0
    plotSegmentationMaskOnImage(  maskStack(:,:,t), imStack(:,:,t), axisRange );
else
    plotSegmentationMaskOnImage(  maskStack(:,:,t), [], axisRange );
end


    function updatePlot( ~, event )
        if event.Character == 'w'
            t = t + 1;
        end;
        if event.Character == 'q'
            t = t - 1;
        end;
        t = mod(t - 1, size(maskStack, 3)) + 1;        
        set(gcf,'numbertitle','off','name',strcat('Frame ',num2str(t)));
        if size(imStack, 1) ~= 0
            plotSegmentationMaskOnImage(  maskStack(:,:,t), imStack(:,:,t), axisRange );
        else
            plotSegmentationMaskOnImage(  maskStack(:,:,t), [], axisRange );
        end
    end

    function plotSegmentationMaskOnImage( mask, im, axisRange )
        if size(im, 1) ~= 0
            imshow( im );
            hold on
        end
        blue = cat(3, zeros(size(mask, 1), size(mask, 2)), ...
            ones(size(mask, 1), size(mask, 2)), ...
            ones(size(mask, 1), size(mask, 2)));
        h = imshow( blue );
        set( h, 'AlphaData', mask .* 0.5);
        
        axis([axisRange(3), axisRange(4), axisRange(1), axisRange(2)]);
        
        hold off
        
    end

end

