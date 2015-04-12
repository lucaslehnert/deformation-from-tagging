function [ imMaskStack ] = gaborTaggingMask( ...
    imStack, windowSigma, threshold, thresholdDecay, gaborM )
%gaborTaggingMask Computes a bitmask based using the Gabor transform of the
%image and then checks if there are more than one maximum in the spectrum
%at a pixel that is higher than the threshold. If there is more than one
%maximum, the pixel is classified as a pixel in a tagging patterns. If
%there is only the zero frequency peak, then the pixel is calssified as not
%having a tagging pattern.

fprintf( 'starting at %s\n', datestr(now) );
startTimer = tic;

if nargin == 3
    gaborM = 64;
    thresholdDecay = 0.5;
elseif nargin == 4
    gaborM = 64;
end
gaborN = 1;

g = gaborgausswin( windowSigma, size(imStack,1) );

imMaskStack = zeros( size(imStack) );

for t = 1:size(imStack, 3)
    
    fprintf( 'starting frame %i at %s\n', t, datestr(now) );
    startTimerFrame = tic;
    
    im = imStack(:,:,t);
    c = dgt2( im, g, gaborN, gaborM );
    [ My, Ny, Mx, Nx ] = size(c);
    
    for nx = 1:Nx
        for ny = 1:Ny

            spectrum = fftshift( reshape( c(:,ny,:,nx), My, Mx ) );
            bw = imregionalmax(abs(spectrum), 8);
            [ i, j ] = find(bw);
            local_max = [ i'; j' ; spectrum(bw)' ]';
            local_max_sorted = sortrows(local_max,3);
            local_max_sorted = local_max_sorted(end:-1:1,:);

            if size( local_max_sorted, 1 ) > 1 && ...
                    abs( local_max_sorted(2,3) ) > ...
                    threshold * exp( - thresholdDecay * (t-1) )
                imMaskStack( ny, nx, t ) = 1;
            else
                imMaskStack( ny, nx, t ) = 0;
            end

        end
    end
    
    fprintf( 'finished frame %i at %s, time needed: %d sec\n', ...
        t, datestr(now), toc(startTimerFrame) );
    
end

fprintf( 'done at %s\n', datestr(now) );
fprintf( 'total time %d sec\n', toc(startTimer) );

end

