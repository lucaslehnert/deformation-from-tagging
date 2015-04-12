function [ Etrace ] = traceTensorField( E )
%tensorFieldTrace Computes the trace of the tensor field and saves it in a
%matrix stack.

Etrace = zeros( size(E, 1), size(E, 2), size(E, 5) );

for t = 1:size(E, 5)
    for i = 1:size(E, 1)
        for j = 1:size(E, 2)
            Eijt = reshape( E(i,j,:,:,t), 2, 2 );
            Etrace(i,j,t) = trace(Eijt);
        end
    end
end



end

