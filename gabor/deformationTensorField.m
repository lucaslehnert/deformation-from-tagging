function [ F, E, omegauv ] = deformationTensorField( ...
    imTagV, imTagH, imTagVRef, imTagHRef, windowSigma )
%DEFORMATIONTENSORFIELD This function computes the deformation tensor field
%for the given images.
%
% [ F, E, omegauv ] = deformationTensorField( ...
%                      imTagV, imTagH, imTagVRef, imTagHRef, windowSigma )
%   imTagV      Vertical tagging image
%   imTagH      Horizontal tagging image
%   imTagVRef   Vertical tagging image used as a reference
%   imTagHRef   Vertical tagging image used as a reference
%   windowSigma Sigma used for the Gabor transform window
%   F           Deformation tensor field, (x,y,:,:) gives tensor at (x,y)
%   E           Lagrange-Green tensor field, same indexing as F
%   omegauv     Omega vector field for imTagV and imTagH
%   gaborCoeff  Gabor coefficients for imTagV and imTagH
%
% Last index in omegauvT and gaborCoeffT indicates the tagging direction.

% Resolution and window used for Gabor transform.
M = 32;
N = 1;
gWin = gaborgausswin( windowSigma, size( imTagV, 1 ) );
% Parameter for solving the linear system for the deformation tensor.
default_F_solver = 'gmres';
F_solver = default_F_solver;

% Compute gabor transform and frequency vector fields (omega) for different
% tagging directions and frames.
cTagV = dgt2( imTagV, gWin, N, M );
cTagH = dgt2( imTagH, gWin, N, M );
omegauvTagV = frequencyfield(cTagV);
omegauvTagH = frequencyfield(cTagH);
clear cTagV;
clear cTagH;

cTagVRef = dgt2( imTagVRef, gWin, N, M );
cTagHRef = dgt2( imTagHRef, gWin, N, M );
omegauvTagVRef = frequencyfield(cTagVRef);
omegauvTagHRef = frequencyfield(cTagHRef);
clear cTagVRef;
clear cTagHRef;

% gaborCoeff = struct( 'verticalTagging', cTagV, ...
%     'horizontalTagging', cTagH, ...
%     'verticalTaggingReference', cTagVRef, ...
%     'horizontalTaggingReference', cTagHRef );
omegauv = struct( 'verticalTagging', omegauvTagV, ...
    'horizontalTagging', omegauvTagH, ...
    'verticalTaggingReference', omegauvTagVRef, ...
    'horizontalTaggingReference', omegauvTagHRef );

disp('done transforms, calculating tensors');

% Compute deformation tensor field F
F = zeros( size( imTagV, 1 ), size( imTagH, 2 ), 2, 2 );
E = zeros( size( imTagV, 1 ), size( imTagH, 2 ), 2, 2 );

for i = 1:size(imTagV, 1)
    for j = 1:size(imTagV, 2)
        
        % compute deformation tensor at (i,j)
        omegaTagVt = reshape(omegauvTagV(i,j,:), 1,2);
        omegaTagHt = reshape(omegauvTagH(i,j,:), 1,2);
        omega_t = [ omegaTagVt ; omegaTagHt ];
        
        omegaTagVt0 = reshape(omegauvTagVRef(i,j,:), 1,2);
        omegaTagHt0 = reshape(omegauvTagHRef(i,j,:), 1,2);
        omega_t0 = [ omegaTagVt0 ; omegaTagHt0 ];
        
        % compute deformation tensor
        if strcmp( F_solver, 'inv' )
            Fij = inv( omega_t' * omega_t ) * omega_t' * omega_t0;
        elseif strcmp( F_solver, 'mldivide') 
            % Same as running 
            % Fij = ( omega_t' * omega_t ) \ ( omega_t' * omega_t0 );
            omega_tt = omega_t' * omega_t;
            A = [ omega_tt(1,1), omega_tt(1,2), 0 ;
                  0,             omega_tt(1,1), omega_tt(1,2) ;
                  omega_tt(2,1), omega_tt(2,2), 0 ;
                  0,             omega_tt(2,1), omega_tt(2,2) ];
            omega_tt0 = omega_t' * omega_t0;
            B = omegatt0(:);
            x = mldivide( A, B );
            Fij(1,1) = x(1);
            Fij(1,2) = x(2);
            Fij(2,1) = x(2);
            Fij(2,2) = x(3);
        elseif strcmp( F_solver, 'gmres')         
            A = omega_t' * omega_t;
            B = omega_t' * omega_t0;
            Fij(:,1) = gmres(A, B(:,1));
            Fij(:,2) = gmres(A, B(:,2));
        end
        F(i, j, :, :) = Fij;
        Eij = 0.5 .* ( Fij' * Fij - eye(2) );
        E(i, j, :, :) = Eij;
        
    end
end
    

end

