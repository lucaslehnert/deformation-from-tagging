function [ Fsmooth, Esmooth ] = smoothDeformationTensorField( ...
    F, sigmaSpacial, sigmaTemporal )
%smoothDeformationTensorField Smoothes the given deformation tensor field
%spacially and temporally and recomputed the Green-Lagrange strain tensors
%based on the smoothed deformation field.
%
% Parameters:
%   T: Tensor field, indexed with (i,j,k,l) where [i,j] vary spacially and
%       [k,l] are indices varying over each tensor entry.
%   sigma: Standard deviation used for gaussian filter to smooth spacially.
%   sigmaTemporal: Standard deviation used for gaussian filter to smooth
%       temporally.
%
% Returns:
%   Tsmooth: Smoothed tensor field.
%
% Default values:
%   sigmaSpacial = 1
%   filterSize = 6
%   temporalWindowSize = 2
%

disp('Smooth defromation tensor field and calculate smoothed strain')
Fsmooth = smoothTensorField( F, sigmaSpacial, sigmaTemporal );
Esmooth = zeros(size(F));
for t = 1:size(Fsmooth, 5)
    
    for i = 1:size(Fsmooth, 1)
        for j = 1:size(Fsmooth, 2)
            
            Fijt = reshape(Fsmooth(i,j,:,:,t), 2, 2);
            Esmooth(i,j,:,:,t) = 0.5 .* ( Fijt' * Fijt - eye(2) );
            
        end
    end
    
end


end

