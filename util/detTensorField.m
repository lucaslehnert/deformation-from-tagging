function [ Edet ] = detTensorField( E )
%detTensorField Computes the determinant of the tensor field and saves it 
%in a matrix stack.

Edet = zeros( size(E, 1), size(E, 2), size(E, 5) );

for t = 1:size(E, 5)
    for i = 1:size(E, 1)
        for j = 1:size(E, 2)
            Eijt = reshape( E(i,j,:,:,t), 2, 2 );
            Edet(i,j,t) = det(Eijt);
        end
    end
end



end

