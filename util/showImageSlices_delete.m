
imStack = imgs_shortax.grid_add(:,:,:,1);
imStack = imStack(60:190,60:190,:);
[X,Y,Z] = meshgrid(1:size(imStack,1), 1:size(imStack,2), 0:6.4:(6.4*(size(imStack,3)-1)));

figure
set(gcf, 'Renderer','OpenGL');
for sliceInd = 1:size(imStack,3)
    [Xs,Ys] = meshgrid(1:size(imStack,1), 1:size(imStack,2));
    Zs = ones(size(Xs)) .* (sliceInd-1) .* 6.4;
    s = slice(X,Y,Z,imStack,Xs,Ys,Zs,'linear');
    set(s,'edgecolor','none')
    hold on
end

colormap(gray);

xlabel('x');
ylabel('y');
zlabel('z');

axis equal
hold off
