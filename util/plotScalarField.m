function [  ] = plotScalarField( ...
    scalarFieldStack, imStack, imMask, axisRange, scalarRange )
%plotScalarField plots a scalar field overlayed with transparency on a gray
%scale image.
%
% plotScalarField( scalarFieldStack, imStack )
% plotScalarField( scalarFieldStack, imStack, imMask )
% plotScalarField( scalarFieldStack, imStack, imMask, axisRange )
% plotScalarField( scalarFieldStack, imStack, imMask, axisRange, scalarRange )
%
% Parameters:
%   scalarFieldStack:   Scalar field stack with indexing (i,j,k), where
%                       (i,j) are pixel coordinates and k ranges over the
%                       stack slices.
%   imStack:            Image stack with indexing (i,j,k). Must have the
%                       same size as scalarFieldStack. 
%   imMask:             Mask used for the scalar field overlay. Indexing is
%                       (i,j,k) and must have the same size as
%                       scalarFieldStack.
%   axisRange:          Range of the image in which the plot should be
%                       shown.
%   scalarRange:        Range to which the color map will be clipped.
%                       Default is to use the maximum and minimum value of
%                       the provided scalar field.
%

if nargin == 2
    imMask = [];
    axisRange = [ 1, size(scalarFieldStack, 1), 1, ...
        size(scalarFieldStack, 2) ];
elseif nargin == 3
    axisRange = [ 1, size(scalarFieldStack, 1), 1, ...
        size(scalarFieldStack, 2) ];
end

if size( imMask, 1 ) == 0
    imMask = ones( size( scalarFieldStack ) );
end

t = 1;
figure('KeyPressFcn', @updatePlot);
set(gcf,'numbertitle','off','name',strcat('Frame ',num2str(t)));
plotStrainTensorMaskedAtTime( scalarFieldStack, imStack, imMask, t );

set(gca,'Position',[0.04 0.11 0.8 0.8]);
set(gca,'units','centimeters')
pos = get(gca,'Position');
ti = get(gca,'TightInset');
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 pos(3)+ti(1)+ti(3) pos(4)+ti(2)+ti(4)]);

    function updatePlot( ~, event )
        if event.Character == 'w'
            t = t + 1;
        end;
        if event.Character == 'q'
            t = t - 1;
        end;
        t = mod(t - 1, size(imStack, 5)) + 1;
        set(gcf,'numbertitle','off','name',strcat('Frame ',num2str(t)));
        plotStrainTensorMaskedAtTime( scalarFieldStack, imStack, ...
            imMask, t );
    end

    function plotStrainTensorMaskedAtTime( ...
            scalarFieldStack, imStack, imMask, t )
        
        % draw plot
        %   adopted from http://www.mathworks.com/matlabcentral/answers/45348-convert-matrix-to-rgb
        imRGB = zeros( size(imStack(:,:,t), 1), size(imStack(:,:,t), 2), 3);
        imRGB(:,:,1) = imStack(:,:,t);
        imRGB(:,:,2) = imStack(:,:,t);
        imRGB(:,:,3) = imStack(:,:,t);

        imh = imshow( imRGB );
        set( imh, 'AlphaData', 0.3 );
        set( gca, 'visible', 'off' );
        hold on
        
        h = imagesc( scalarFieldStack(:,:,t) );
        colormap(jet(256));
        colorbar
        set(gca,'children',flipud(get(gca,'children')))
        set( h, 'AlphaData', 1 .* imMask(:,:,t)  );
        caxis( scalarRange );
        axis([axisRange(3), axisRange(4), axisRange(1), axisRange(2)]);
        
        set(gca, 'YTick', []);
        set(gca, 'XTick', []);

        axis square
        
        hold off

    end


end

