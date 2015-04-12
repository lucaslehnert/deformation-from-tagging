function [ omegaField ] = omegaFieldFromTagMRI( ...
    imStack, gaborSigma, gaborN, gaborM, freqPeakMode )
%omegaFieldFromTagMRI Computes the omega frequency vector field for the
%given tag images
%
% [TODO]
%
% Parameters:
%   imStack:
%   gaborSigma
%   gaborN: 
%   gaborM:
%   freqPeakMode:
%
% Return:
%   omegaField: 
%

disp( sprintf( 'starting at %s', datestr(now) ) );
startTimer = tic;

if nargin ~= 4 && nargin ~= 5
    error( 'Wrong number of arguments, number was %i, but must be 4 or 5', nargin );
end

omegaField = zeros( [ size(imStack,1)/gaborN, size(imStack,2)/gaborN, ...
    2, size(imStack,3) ] );

for t = 1:size(imStack, 3)
    
    disp( sprintf( 'starting frame %i at %s', t, datestr(now) ) );
    startTimerFrame = tic;
    
    im = imStack(:,:,t);
    g = gaborgausswin( gaborSigma, size(im,1) );
    c = dgt2( im, g, gaborN, gaborM );
    
    if nargin == 4
        omegaField(:,:,:,t) = frequencyfield(c);
    elseif nargin == 5
        omegaField(:,:,:,t) = frequencyfield(c, freqPeakMode);
    end
    
    disp( sprintf( 'finished frame %i at %s, time needed: %d sec', ...
        t, datestr(now), toc(startTimerFrame) ) );
    
end

disp( sprintf( 'done at %s', datestr(now) ) );
disp( sprintf( 'total time %d sec', toc(startTimer) ) );


end

