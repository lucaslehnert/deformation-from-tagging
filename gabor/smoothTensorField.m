function [ Tsmooth ] = smoothTensorField( T, sigma, sigmaTemporal )
%smoothTensorField Smooth the given tensor field by smoothing each tensor 
%element spacially with a gaussian filter.
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

TsmoothSpacial = zeros(size(T));
filterSpacial = fspecial('gaussian', ceil(6.0 * sigma), sigma);
for t = 1:size(T, 5)
    
    T11t = reshape(T(:,:,1,1,t), size(T, 1), size(T, 2));
    TsmoothSpacial(:,:,1,1,t) = imfilter(T11t, filterSpacial);
    T12t = reshape(T(:,:,1,2,t), size(T, 1), size(T, 2));
    TsmoothSpacial(:,:,1,2,t) = imfilter(T12t, filterSpacial);    
    T21t = reshape(T(:,:,2,1,t), size(T, 1), size(T, 2));
    TsmoothSpacial(:,:,2,1,t) = imfilter(T21t, filterSpacial);
    T22t = reshape(T(:,:,2,2,t), size(T, 1), size(T, 2));
    TsmoothSpacial(:,:,2,2,t) = imfilter(T22t, filterSpacial);
    
end

Tsmooth = zeros(size(T));

if nargin == 3
    disp('smoothing in time ...');
    N = ceil( sigmaTemporal * 6.0 );
    x = linspace(-N/2,N/2,N);
    filterWin = (x.^2) ./ ( 2 * sigmaTemporal^2 );
    filterTemporal = filterWin ./ sum( filterWin );
    for i = 1:size(T, 1)
        for j = 1:size(T, 2)
            
            T11ij = reshape( T(i,j,1,1,:), 1, size(T, 5));
            Tsmooth(i,j,1,1,:) = conv( T11ij, filterTemporal, 'same');
            T12ij = reshape( T(i,j,1,2,:), 1, size(T, 5) );
            Tsmooth(i,j,1,2,:) = conv( T12ij, filterTemporal, 'same');
            T21ij = reshape( T(i,j,2,1,:), 1, size(T, 5) );
            Tsmooth(i,j,2,1,:) = conv( T21ij, filterTemporal, 'same');
            T22ij = reshape( T(i,j,2,2,:), 1, size(T, 5) );
            Tsmooth(i,j,2,2,:) = conv( T22ij, filterTemporal, 'same');

        end
    end
else
    Tsmooth = TsmoothSpacial;
end


end

