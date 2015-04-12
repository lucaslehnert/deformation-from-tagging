function [ omega, i, j ] = maxfreqnonzero( spectrum, mode )
%maxfreqnonzero Computes the second local maximum frequency peak in the
%spectrum spec
%
% [TODO]
% maxfreqnonzero( spectrum ) 
% maxfreqnonzero( spectrum, mode )
%
% Parameters:
%   spectrum:
%   mode:
%
% Returns:
%   omega:
%   i:
%   j:
%
% [ omega,i,j ] = maxfreqnonzero( spec )
%   spec    Frequency spectrum
%   omega   Frequency vector
%   i,j     Indices of detected peak in matrix spec
%
% [ omega,i,j ] = maxfreqnonzero( spec, mode )
%   mode    Clipping mode, default is to use the peak with positive
%           imaginary amplitude.
%
% The matrix spec is assumed to be square and not fft-shifted. It can be
% complex.
%

if nargin == 1
    mode = 'posimag';
elseif ~strcmp( mode, 'posimag' ) && ...
        ~strcmp( mode, 'pos_omegax' ) && ...
        ~strcmp( mode, 'pos_omegay' )
    error( 'Invalid mode %s, must be posimag | pos_omegax | pos_omegay.',  mode );
end

spec_shifted = fftshift(spectrum);

if strcmp( mode, 'pos_omegax' )
    % Take omegax >= 0 halfspace. 
    [ m, n ] = size(spec_shifted);
    if mod( n, 2 ) == 1
        nHalf = ceil( n / 2.0 );
    else
        nHalf = n / 2.0 + 1;
    end
    if mod( m, 2 ) == 1
        mHalf = ceil( m / 2.0 );
    else
        mHalf = m / 2.0 + 1;
    end
    spec_shifted = spec_shifted(:,nHalf:n);
    spec_shifted( mHalf+1:m, 1 ) = 0;
elseif strcmp( mode, 'pos_omegay' )
    % Take omegay >= 0 halfspace. 
    [ m, n ] = size(spec_shifted);
    if mod( n, 2 ) == 1
        nHalf = ceil( n / 2.0 );
    else
        nHalf = n / 2.0 + 1;
    end
    if mod( m, 2 ) == 1
        mHalf = ceil( m / 2.0 );
    else
        mHalf = m / 2.0 + 1;
    end
    spec_shifted = spec_shifted(1:mHalf,:);
    spec_shifted( mHalf, 1:nHalf-1 ) = 0;    
end

bw = imregionalmax(abs(spec_shifted), 8);
[ i, j ] = find(bw);
local_max = [ i'; j' ; spec_shifted(bw)' ]'; % sort over complex spectrum
local_max_sorted = sortrows(local_max,3);
local_max_sorted = local_max_sorted(end:-1:1,:);

% Pick the second highest frequency peak with a positive imaginary part. If
% there is none, then use the 0-frequency peak.
% Here we determine the index of the peak in local_max_sorted.
if size( local_max_sorted, 1 ) == 1
    peakInd = 1;
elseif size( local_max_sorted, 1 ) == 2
    peakInd = 2;
elseif strcmp( mode, 'posimag' )
    if abs( local_max_sorted(2,3) ) >= abs( local_max_sorted(3,3) ) && ...
            imag( local_max_sorted(2,3) ) >= 0 
        peakInd = 2;
    elseif nargin == 2
        peakInd = 3;
    end
else 
    peakInd = 2;
end

max_i = local_max_sorted( peakInd, 1 );
max_j = local_max_sorted( peakInd, 2 );

zeropeak_i = local_max_sorted(1,1);
zeropeak_j = local_max_sorted(1,2);

% Size of the full spectrum is needed for frequency calculation (omega
% values need to be in radians).
M = size(spectrum,1);

omegax = max_j - zeropeak_j;
omegay = max_i - zeropeak_i;
omega = [ omegax; omegay ] ./ (M * 2) ;

end

