function [ F, E ] = deformationTensorFromOmegaField( ...
                    omegauvTagH, omegauvTagV, timeRef, sigmaSpacial, ...
                    filterSize, temporalWindowSize )
%deformationTensorFromOmegaField This function computes the deformation
%tensors and strain tensors from the given omegafields.
%
% deformationTensorFromOmegaField( omegauvTagH, omegauvTagV, timeRef)
%   Calculate deformation tensors without smoothing.
% deformationTensorFromOmegaField( omegauvTagH, omegauvTagV, timeRef, ...
%   sigmaSpacial, filterSize )
%   Calculate deformation tensors with only spacial smoothing.
% deformationTensorFromOmegaField( omegauvTagH, omegauvTagV, timeRef, ...
%   sigmaSpacial, filterSize, temporalWindowSize )
%   Calculate deformation tensors with only spacial and temporal smoothing.
%
% From the frequency fields the deformation and stain tensor fields are
% calculated. The deformation and strain tensors are relative to the
% reference time given by timeRef, they are not calculated from frame to
% frame.
%
% The frequency fields are indexed with (i,j,d,t), where [i,j] range over 
% pixel/voxel coordinates, d is the index corresponding to the x and y 
% coordinates of a frequency vector and t is the time index for each
%
% The returned tensor fields are indexed with (i,j,k,l) where the [i,j]
% range over pixel/voxels and [k,l] are indices ranging over the tensor
% entries.
%
% Parameters:
%   omegauvTagH: Frequency field for horizontal tagging direction.
%   omegauvTagV: Frequency field for vertical tagging direction.
%   timeRef: Reference frame index.
%   sigmaSpacial: optional. If specified the tensor fields are smoothed 
%       spacially with a gaussian of the given standard deviation.
%   filterSize: optional. If specified the tensor fields are smoothed 
%       spacially with Gaussian filter of this size.
%   temporalWindowSize: optional. If specified the tensor fields are
%       smoothed temporally with a filter of this size.
%
% Returns:
%   F: Deformation tensor field.
%   E: Strain tensor field.
%
% [REMOVE]
% [ F, E ] = deformationTensorFromOmegaField( omegauvt, timeRef )
%   omegauvt    Frequency field indexed with (i,j,d,t)
%   timeRef     Time index that is used as reference frame
%   F           Deformation tensor field, tensor at (i,j) is (i,j,:,:)
%   E           Strain tensor field, tensor at (i,j) is (i,j,:,:)
%

fprintf( 'starting at %s', datestr(now) );
startTimer = tic;

% Solver that should be used to solve the linear system for the deformation 
% tensor field.
F_solver = 'gmres';

F = zeros( size( omegauvTagH, 1 ), size( omegauvTagH, 2 ), 2, 2, size(omegauvTagH, 4) );
E = zeros( size( omegauvTagH, 1 ), size( omegauvTagH, 2 ), 2, 2, size(omegauvTagH, 4) );

for t = 1:size(omegauvTagH, 4)
    
    startTimerFrame = tic;
    
    disp( sprintf( 'starting frame %i at %s', t, datestr(now) ) );
    
    for i = 1:size(omegauvTagH, 1)
        for j = 1:size(omegauvTagH, 2)
            
            omegaTagVt = reshape(omegauvTagV(i,j,:,t), 1,2);
            omegaTagHt = reshape(omegauvTagH(i,j,:,t), 1,2);
            omega_t = [ omegaTagVt ; omegaTagHt ];
            
            omegaTagVt0 = reshape(omegauvTagV(i,j,:,timeRef), 1,2);
            omegaTagHt0 = reshape(omegauvTagH(i,j,:,timeRef), 1,2);
            omega_t0 = [ omegaTagVt0 ; omegaTagHt0 ];
            
            % compute deformation tensor
            if strcmp( F_solver, 'inv' )
                Fij = inv( omega_t' * omega_t ) * omega_t' * omega_t0;
            elseif strcmp( F_solver, 'mldivide') 
                % Same as running 
                % Fij = ( omega_t' * omega_t ) \ ( omega_t' * omega_t0 );
                % Fij = mldivide( omega_t' * omega_t, omega_t' * omega_t0 );
                omega_tt = omega_t' * omega_t;
                A = [ omega_tt(1,1), omega_tt(1,2), 0 ;
                      0,             omega_tt(1,1), omega_tt(1,2) ;
                      omega_tt(2,1), omega_tt(2,2), 0 ;
                      0,             omega_tt(2,1), omega_tt(2,2) ];
                omega_tt0 = omega_t' * omega_t0;
                B = omega_tt0(:);
                x = mldivide( A, B );
                Fij(1,1) = x(1);
                Fij(1,2) = x(2);
                Fij(2,1) = x(2);
                Fij(2,2) = x(3);
            elseif strcmp( F_solver, 'gmres')  
                % do not compute omega_t' * omega_t but directly construct
                % the system Omegat_t * F = Omega_t0, convert it into an
                % overdetermine system A * x = b and then solve A'*A * x =
                % A'*b.
                A = [ omega_t(1,1), omega_t(1,2), 0            ;
                      0,            omega_t(1,1), omega_t(1,2) ;
                      omega_t(2,1), omega_t(2,2), 0            ;
                      0,            omega_t(2,1), omega_t(2,2) ];
                b = omega_t0';
                b = b(:);
                
                [ x, flag ] = gmres( A' * A, A' * b, [], [], [], [], [], [ 1 0 1 ]' );
                if flag ~= 0
                    fprintf('    gmres Fij1 flag: %i at (t,i,j) = (%i,%i,%i)', flag, t, i, j);
                end
                
                Fij(1,1) = x(1);
                Fij(1,2) = x(2);
                Fij(2,1) = x(2);
                Fij(2,2) = x(3);
                
%                 A = omega_t' * omega_t;
%                 B = omega_t' * omega_t0;
%                 
%                 [ Fij1, flag ] = gmres(A, B(:,1));
%                 if flag ~= 0
%                     fprintf('    gmres Fij1 flag: %i at (t,i,j) = (%i,%i,%i)', flag, t, i, j);
%                 end
%                 Fij(:,1) = Fij1;
%                 [ Fij2, flag ] = gmres(A, B(:,2));
%                 if flag ~= 0
%                     fprintf('    gmres Fij2 flag: %i at (t,i,j) = (%i,%i,%i)', flag, t, i, j);
%                 end
%                 Fij(:,2) = Fij2;
            end
            F(i,j,:,:,t) = Fij;
%             Eij = 0.5 .* ( Fij' * Fij - eye(2) );
%             E(i,j,:,:,t) = Eij;
            
        end
    end
    
    fprintf( 'finished frame %i at %s, time needed: %d sec', ...
        t, datestr(now), toc(startTimerFrame) );
    
end

if nargin == 6
    disp('smooth deformation tensors');
    F = smoothTensorField( F, sigmaSpacial, filterSize, temporalWindowSize );
elseif nargin == 5
    disp('smooth deformation tensors');
    F = smoothTensorField( F, sigmaSpacial, filterSize );
end

for t = 1:size(F, 5)
    
    for i = 1:size(F, 1)
        for j = 1:size(F, 2)
            
            Fijt = reshape(F(i,j,:,:,t), 2, 2);
            E(i,j,:,:,t) = 0.5 .* ( Fijt' * Fijt - eye(2) );
            
        end
    end
    
end


fprintf( 'done at %s', datestr(now) );
fprintf( 'total time %d sec', toc(startTimer) );

end

