function [ imStackScaled ] = scaleImageStack( ...
    imStack, axisRange, mode, offset )
%scaleImageStack normalizes the given image stack to [0,1].
%
% [ imStackScaled ] = scaleImageStack( imStack )
% [ imStackScaled ] = scaleImageStack( imStack, axisRange )
% [ imStackScaled ] = scaleImageStack( imStack, axisRange, mode )
% [ imStackScaled ] = scaleImageStack( imStack, axisRange, mode, offset )
% [ imStackScaled ] = scaleImageStack( imStack, axisRange, [], offset )
%
% There are three modes for scaling, the default is all:
%   all:    The range of the values of the whole image stack is used to
%           determine the scaling, i.e. the max and min over the whole 
%           sequence is calculated.
%   first:  The range of the first image in the stack is used to determine
%           the scaling. This scaling is then applied to all other images,
%           i.e. only the max and min over the first image are used, but
%           are then applied to the whole stack.
%   fbf:    frame-by-frame, each frame in the image stack is normalized
%           independently.
%
% The parameters are the following:
%   imStack:    Image stack that is to be scaled, indexed with (i,j,k) with
%               (i,j) being pixel coordinates and k being the index over
%               the image stack.
%   axisRange:  The range in pixel coordinates over which the scaling
%               should be applied. This is indexed with [ imin, imax, jmin,
%               jmax ]. If not specified, the whole stack is used.
%   mode:       Either 'all', 'first', or 'fbf'. The default is 'all', if
%               [] is passed the default is used.
%   offset:     Offset given as one non-negaitve integer that is used to
%               further restrict the axis range (i.e. the range becomes by
%               offset pixels smaller.
%
% Returned is the scaled image stack, with the same size and indexing as
% the input stack.

if nargin == 1
    axisRange = [ 1, size(imStack, 1), 1, size(imStack, 2) ];
    mode = 'all';
    offset = 0;
elseif nargin == 2
    mode = 'all';
    offset = 0;
elseif nargin == 3
    offset = 0;
end

if size(mode, 1) == 0
    mode = 'all';
end
if size(axisRange, 1) == 0
    axisRange = [ 1, size(imStack, 1), 1, size(imStack, 2) ];
end

if ~strcmp( mode, 'fbf' )
    if strcmp( mode, 'all')
        im = imStack( axisRange(1)+offset:axisRange(4)-offset, ...
            axisRange(3)+offset:axisRange(4)-offset, :);
    elseif strcmp( mode, 'first')
        im = imStack( axisRange(1)+offset:axisRange(4)-offset, ...
            axisRange(3)+offset:axisRange(4)-offset, 1);
    end
    intensityMax = max(im(:));
    intensityMin = min(im(:));

    fprintf( 'scaling to range [%f, %f]\n', intensityMin, intensityMax );

    imStackScaled = (imStack - intensityMin) ./ (intensityMax - intensityMin);
    imStackScaled(imStackScaled > 1) = 1;
    imStackScaled(imStackScaled < 0) = 0;
else
    imStackScaled = zeros( size( imStack ) ); 
    for k = 1:size( imStack, 3 )
        im = imStack( axisRange(1)+offset:axisRange(4)-offset, ...
            axisRange(3)+offset:axisRange(4)-offset, k);
        intensityMax = max(im(:));
        intensityMin = min(im(:));
        
        imScaled = (imStack(:,:,k) - intensityMin) ./ (intensityMax - intensityMin);
        imScaled(imScaled > 1) = 1;
        imScaled(imScaled < 0) = 0;
        imStackScaled(:,:,k) = imScaled;
    end
end


end

