% path( pathdef_linux );
% path( pathdef_laptop );
% ltfatstart;
global DATA_PATH
DATA_PATH = strcat( pwd, '/dataremote/' );

fprintf( 'dataDir: %s\n', DATA_PATH );

dataset = '07-30314-03';
[ imgs_shortax, ~ ] = readTaggedMRI( dataset );
imStackGrid = imgs_shortax( 4 ).grid_add;
axisRange = [91,174,71,168];
imStackGrid = scaleImageStack( imStackGrid, axisRange, 'first', 10 );

load('plots/segmentation-mask/07-30314-03/taggingPlotSegmentationMask.mat');

[ Fasym,Easym,~,~,pasym ] = ...
    readExperimentResults( 'heartdeformation_slice4_sigma07', dataset, false );
Fasym = reshape(Fasym(:,:,:,:,1,:), 256,256,2,2,20);
Easym = reshape(Easym(:,:,:,:,1,:), 256,256,2,2,20);
[ FasymSmooth,EasymSmooth,~,~,pasymSmooth ] = ...
    readExperimentResults( 'heartdeformation_slice4_sigma07', dataset, true );
FasymSmooth = reshape(FasymSmooth(:,:,:,:,1,:), 256,256,2,2,20);
EasymSmooth = reshape(EasymSmooth(:,:,:,:,1,:), 256,256,2,2,20);

T = size(Fasym, 5);

for t = 1:T
    fprintf( 'plotting frame %02d\n', t );
    plotTensorCoord( Fasym(:,:,:,:,t), imStackGrid(:,:,t), ...
        imMaskStackGridTweak(:,:,t), 5, 0.1, axisRange );
    deformationTensorFile = sprintf( ...
        'plots/deformation-tensor-frames/deformation-tensor-asym-nonsmooth-frame%02d.pdf', t);
    export_fig( deformationTensorFile, '-q60', '-transparent' );
    close all
end

for t = 1:T
    fprintf( 'plotting frame %02d\n', t );
    plotTensorCoord( FasymSmooth(:,:,:,:,t), imStackGrid(:,:,t), ...
        imMaskStackGridTweak(:,:,t), 5, 0.1, axisRange );
    deformationTensorFile = sprintf( ...
        'plots/deformation-tensor-frames/deformation-tensor-asym-smooth-frame%02d.pdf', t);
    export_fig( deformationTensorFile, '-q60', '-transparent' );
    close all
end

for t = 1:T
    fprintf( 'plotting frame %02d\n', t );
    plotTensorCoord( Fasym(:,:,:,:,t), ...
        Easym(:,:,t), imMaskStackGrid(:,:,t), 3, 0.1, ...
        axisRange, true, ['k','k'], [-1,1] );
    deformationTensorFile = sprintf( ...
        'plots/strain-tensor-frames/strain-deformation-tensor-asym-nonsmooth-frame%02d.pdf', t);
    export_fig( deformationTensorFile, '-q60', '-opengl' );
    close all
end

for t = 1:T
    fprintf( 'plotting frame %02d\n', t );
    plotTensorCoord( FasymSmooth(:,:,:,:,t), ...
        EasymSmooth(:,:,t), imMaskStackGrid(:,:,t), 3, 0.1, ...
        axisRange, true, ['k','k'], [-1,1] );
    deformationTensorFile = sprintf( ...
        'plots/strain-tensor-frames/strain-deformation-tensor-asym-smooth-frame%02d.pdf', t);
    export_fig( deformationTensorFile, '-q60', '-opengl' );
    close all
end






