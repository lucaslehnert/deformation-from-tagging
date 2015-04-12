function [  ] = imshowStack( imStack, axisRange )
%showImageStack plots a stack of images into one plot and allows to scroll
%the image sequence.
%
%   Adopted from Arthur's showImages method implementation.
%
%   showImageStack( im )
%   im is the stack of images that is to be used.
%   showImageStack( im, axisRange )
%   im is the stack of images that is to be used and axis range defines the
%   range in which to show the stack.
%
% For scrolling in the stack use 'q' and 'w' keys.

if nargin == 1
    axisRange = [ 0, size(imStack, 1), 0, size(imStack, 2) ];
end

time = 1;
figure('KeyPressFcn', @updateMRI);
set(gcf,'numbertitle','off','name',strcat('Time ',num2str(time)));
axis square;
imshow( imStack(:,:,time), 'InitialMagnification', 'fit' );
axis([axisRange(3), axisRange(4), axisRange(1), axisRange(2)]);
%axis equal;

    function updateMRI(~, event)
        if event.Character == 'w'
            time = time + 1;
        end;
        if event.Character == 'q'
            time = time - 1;
        end;
        time = mod(time - 1, size( imStack, 3 )) + 1;
        set(gcf,'numbertitle','off','name',strcat('Time ',num2str(time)));
        axis square;
        imshow( imStack(:,:,time) , 'InitialMagnification', 'fit');
        axis([axisRange(3), axisRange(4), axisRange(1), axisRange(2)]);
        %axis equal;
    end

end
