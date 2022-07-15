% function ImageSegmentation(processeddirec,analyzeddirec,dperPix,ParticleDiameter)
     

PixelParticleDiameter = ParticleDiameter/dperPix;
LowerDiameterPixelBuffer = 20; %pixels
UpperDiameterPixelBuffer = 100; %pixels
ParticleSubtractionBuffer = 5; %How much to add to the found particle radius to remove halo of particle

direc = [processeddirec '\HistMatchImages'];
A = dir(direc); Runs = {};
[Runs{1:length(A),1}] = A.name;
Runs(strcmp(Runs,'.'))=[]; Runs(strcmp(Runs,'..'))=[];
Runs = sortrows(Runs); NumOfRuns = numel(Runs); clear A Runs;
    
for i = 1:NumOfRuns
    A = dir([processeddirec '\HistMatchImages\R' num2str(i) '\*.tiff']); Images = {};
    [Images{1:length(A),1}] = A.name;
    Images(strcmp(Images,'.'))=[]; Images(strcmp(Images,'..'))=[];
    Images = sortrows(Images)'; clear A

    for j = 1:numel(Images)
        im_orig = imread([processeddirec '\HistMatchImages\R' num2str(i) filesep Images{j}]);
        
        %First binarize the image
        im_bin = imbinarize(im_orig,0.7);
        im_bin = imfill(im_bin,'holes');%Fill in missing spots

        %Find the large particles
        area_large_particle = pi/4*(PixelParticleDiameter+UpperDiameterPixelBuffer)^2;
        smallarea_large_particle = pi/4*(PixelParticleDiameter-LowerDiameterPixelBuffer)^2;
        remove_small = bwareafilt(im_bin,[smallarea_large_particle...
            area_large_particle]); %remove particles smaller than input

        stats = regionprops('table',remove_small,'Centroid','MajorAxisLength'...
            ,'MinorAxisLength');
        centers = stats.Centroid;
        ParticleCenters{i,1}{j,1} = centers;
        diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
        ParticleRadii{i,1}{j,1} = diameters/2; radii = diameters/2;
        %This next part will create an image of the circles so that we can
        %subtract it from the original to take out the inertial particles.
        I = zeros(250,400);
        for m = 1:numel(radii)
            imageSizeX = 400;
            imageSizeY = 250;
            [columnsInImage, rowsInImage] = meshgrid(1:imageSizeX,1:imageSizeY); %Generating pixel grid
            % Next create the circle in the image
            centerX = ceil(centers(m,1));
            centerY = ceil(centers(m,2));
            radius = radii(m)+ParticleSubtractionBuffer;
            circlePixels = (rowsInImage - centerY).^2 ...
                +(columnsInImage - centerX).^2 <= radius.^2; %creating logical array that draws
            %circles where large particles are
            %circlePixels is a 2D "logical" array
            %Now add this to the same image with previously drawn particles
            I = I+circlePixels; %logical array
        end
        LogicI = logical(I);
        I = uint16(I.*2.^16); %converts logical array into 16 bit image
        Tracers = im_orig - I;

        imwrite(Tracers,[processeddirec '\Tracer Particles' '\R' num2str(i) '\data_' sprintf('%03d',j) '.tiff'])

        %Now finish processing the inertial images these will remain as 16
        %bit binary
        Inertials = uint16(double(remove_small)*65536);

        imwrite(Inertials,[processeddirec '\Inertial Particles' '\R' num2str(i) '\data_' sprintf('%03d',j) '.tiff'])
    end
end
if ~exist([analyzeddirec '\Tracer Particles'], 'dir')
      mkdir([analyzeddirec '\Tracer Particles'])
end
save([analyzeddirec '\Tracer Particles\ParticleRadiiAndCenters.mat'], 'ParticleCenters','ParticleRadii')

% end