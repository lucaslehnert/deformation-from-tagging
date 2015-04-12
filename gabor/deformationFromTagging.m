function [ F, E, omegaTagV, omegaTagH ] = ...
    deformationFromTagging( ...
    imStackTagVertical, imStackTagHorizontal, gaborWindowSigma, ...
    spectrumSize, defRefFrame, Fsymmetric )
%DEFORMATIONFROMTAGGING This function runs through the whole pipeline of
%the deformation from tagging image method that computes deformation
%tensors from tagging images.
%
% [ F, E, omegaTagV, omegaTagH ] = ...
%    deformationFromTaggingPar( ...
%    imStackTagVertical, imStackTagHorizontal, gaborWindowSigma, ...
%    spectrumSize )
% [ F, E, omegaTagV, omegaTagH ] = ...
%    deformationFromTaggingPar( ...
%    imStackTagVertical, imStackTagHorizontal, gaborWindowSigma, ...
%    spectrumSize, defRefFrame )
% [ F, E, omegaTagV, omegaTagH ] = ...
%    deformationFromTaggingPar( ...
%    imStackTagVertical, imStackTagHorizontal, gaborWindowSigma, ...
%    spectrumSize, defRefFrame, Fsymmetric )
%
% Parameters:
%   imStackTagVertical: Image stack (in time) with vertical tagging
%       pattern.
%   imStackTagHorizontal: Image stack (in time) with horizontal tagging
%       pattern.
%   gaborWindowSigma: Sigma of gaussian window that is used for Gabor
%       transform.
%   spectrumSize: Size of the spectrum calculated with the Gabor transform 
%       (spectrum at each voxel).
%   defRefFrame: Reference frame used for the deformation tensor
%       calculation. Can be set to 'first' to use the first frame of the
%       squence as the reference frame, or can be 'prev' to use the
%       previous frame in the sequence.
%   Fsymmetric: Enforce the deformation tensor to be symmetric, default is
%       true (can be true or false).
%
% Returns:
%   F: Deformation tensor image stack indexed with [i,j,m,n,t], with [i,j] 
%       being pixel coordinate, [m,n] coordinates in the Tensor matrix, and
%       t the time index.
%   E: Green-Lagrange tensor stack, same indexing/dimension as F.
%   omegaTagV: Field of frequency vectors that is calculated from the Gabor
%       transform spectrums from vertical tagging.
%   omegaTagH: Field of frequency vectors that is calculated from the Gabor
%       transform spectrums from horizontal tagging.
%

if nargin == 4
    defRefFrame = 'first';
    Fsymmetric = true;
elseif nargin == 5
    Fsymmetric = true;
end

fprintf( 'starting at %s\n', datestr(now) );
startTimer = tic;

g = gaborgausswin( gaborWindowSigma, size(imStackTagVertical,1) );
gaborN = 1;
gaborM = spectrumSize;

omegaTagV = zeros(size( imStackTagVertical, 1 ), size( imStackTagVertical, 2 ), 2, size(imStackTagVertical, 3) );
omegaTagH = zeros(size( imStackTagVertical, 1 ), size( imStackTagVertical, 2 ), 2, size(imStackTagVertical, 3) );

F = zeros( size( imStackTagVertical, 1 ), size( imStackTagVertical, 2 ), 2, 2, size(imStackTagVertical, 3) );
E = zeros( size( imStackTagVertical, 1 ), size( imStackTagVertical, 2 ), 2, 2, size(imStackTagVertical, 3) );

for t = 1:size( imStackTagVertical, 3 )
    
    fprintf( 'starting frame %i at %s\n', t, datestr(now) );
    startTimerFrame = tic;
    
    % Calculate gabor transforms.
    disp('    Calculating gabor transforms')
    cTagV = dgt2( imStackTagVertical(:,:,t), g, gaborN, gaborM );
    cTagH = dgt2( imStackTagHorizontal(:,:,t), g, gaborN, gaborM );
    
    [ My, Ny, Mx, Nx ] = size(cTagV);
    
    disp('    Run pipeline over the image')
    if Fsymmetric
        disp('        Enforcing defromation tensors to be symmetric.')
    else
        disp('        Defromation tensors can be asymmetric.')
    end
    % From here on the method can be parallelized.
    
    for nx = 1:Nx
        for ny = 1:Ny
           
           % compute omega covectors. 
           specTagV =  reshape( cTagV(:,ny,:,nx), My, Mx );
           [ omegaTagVt, i, j ] = maxfreqnonzero( specTagV, 'pos_omegax' );
           omegaTagV(ny,nx,:,t) = omegaTagVt;
           
           specTagH =  reshape( cTagH(:,ny,:,nx), My, Mx );
           [ omegaTagHt, i, j ] = maxfreqnonzero( specTagH, 'pos_omegay' );
           omegaTagH(ny,nx,:,t) = omegaTagHt;
           
           % create omega vector matrices
           if strcmp( defRefFrame, 'prev') && t > 1
               omegaTagVt0 = reshape(omegaTagV(ny,nx,:,t-1),1,2);
               omegaTagHt0 = reshape(omegaTagH(ny,nx,:,t-1),1,2);
           else
               omegaTagVt0 = reshape(omegaTagV(ny,nx,:,1),1,2);
               omegaTagHt0 = reshape(omegaTagH(ny,nx,:,1),1,2);
           end
           omega_t = [ omegaTagVt' ; omegaTagHt' ];
           omega_t0 = [ omegaTagVt0 ; omegaTagHt0 ];
           
           if Fsymmetric
               % solve linear system with GMRES for a symmetric F
                A = [ omega_t(1,1), omega_t(1,2), 0            ;
                     0,            omega_t(1,1), omega_t(1,2) ;
                     omega_t(2,1), omega_t(2,2), 0            ;
                     0,            omega_t(2,1), omega_t(2,2) ];
               b = omega_t0';
               b = b(:);

               [ x, flag ] = gmres( A' * A, A' * b, [], [], [], [], [], [ 1 0 1 ]' );
               if flag ~= 0
                    fprintf('    gmres Fij1 flag: %i at (t,i,j) = (%i,%i,%i)', flag, t, nx, ny);
               end

               Fij(1,1) = x(1);
               Fij(1,2) = x(2);
               Fij(2,1) = x(2);
               Fij(2,2) = x(3);
           else
               % solve linear system with GMRES for a F (can be assymmetric
               A = [ omega_t(1,1), 0,            omega_t(1,2), 0            ;
                     0,            omega_t(1,1), 0,            omega_t(1,2) ;
                     omega_t(2,1), 0,            omega_t(2,2), 0            ;
                     0,            omega_t(2,1), 0,            omega_t(2,2) ];
               b = omega_t0';
               b = b(:);

               [ Fij, flag ] = gmres( A' * A, A' * b, [], [], [], [], [], [ 1 0 0 1 ]' );
               Fij = reshape( Fij, 2, 2 )';
               if flag ~= 0
                    fprintf('    gmres Fij1 flag: %i at (t,i,j) = (%i,%i,%i)', flag, t, nx, ny);
               end               
           end
           F(ny,nx,:,:,t) = Fij;
           
           % caluclate strain tensor
           E(ny,nx,:,:,t) = 0.5 .* ( Fij' * Fij - eye(2) );
           
        end
    end
    
    fprintf( 'finished frame %i at %s, time needed: %d sec\n', ...
        t, datestr(now), toc(startTimerFrame) );
    
end

fprintf( 'done at %s\n', datestr(now) );
fprintf( 'total time %d sec\n', toc(startTimer) );

end

