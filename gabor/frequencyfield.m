function [ omega ] = frequencyfield( gabor_coeff, freqPeakMode )
%frequencyfield Computes the angular frequency at each spatial index with
%the strongest amplitude.
%
% This function computes the frequency field given the gabor coefficients
% returned by dgt2.
%
% [ omegax, omegay ] = frequencyfield( gabor_coeff )
%

[ My, Ny, Mx, Nx ] = size(gabor_coeff);

omega = zeros(Ny, Nx, 2 );

for nx = 1:Nx
    for ny = 1:Ny
        spectrum = reshape( gabor_coeff(:,ny,:,nx), My, Mx );
        if nargin == 1 
            [ omega_ij, i, j ] = maxfreqnonzero( spectrum );
        else if nargin == 2
            [ omega_ij, i, j ] = maxfreqnonzero( spectrum, freqPeakMode );
        end
        omega(ny,nx,:) = omega_ij;
    end
end

end

