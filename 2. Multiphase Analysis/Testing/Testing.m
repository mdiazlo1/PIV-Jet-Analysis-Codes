PixelParticleDiameter = ParticleDiameter/dperPix;
LowerDiameterPixelBuffer = 20; %pixels
UpperDiameterPixelBuffer = 100; %pixels
ParticleSubtractionBuffer = 5; %How much to add to the found particle radius to remove halo of particle

direc = [processeddirec '\HistMatchImages'];
A = dir(direc); Runs = {};
[Runs{1:length(A),1}] = A.name;
Runs(strcmp(Runs,'.'))=[]; Runs(strcmp(Runs,'..'))=[];
Runs = sortrows(Runs); NumOfRuns = numel(Runs); clear A Runs;
    
% for i = 1:NumOfRuns
    i = 2; 
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
        remove_large = ~logical(remove_small);
        Tracers = uint16(double(im_orig).*remove_large);

        imwrite(Tracers,[processeddirec '\Tracer Particles' '\R' num2str(i) '\data_' sprintf('%03d',j) '.tiff'])

        %Now finish processing the inertial images these will remain as 16
        %bit binary
        Inertials = uint16(double(remove_small)*65536);

        imwrite(Inertials,[processeddirec '\Inertial Particles' '\R' num2str(i) '\data_' sprintf('%03d',j) '.tiff'])
    end
% end
if ~exist([analyzeddirec '\Tracer Particles'], 'dir')
      mkdir([analyzeddirec '\Tracer Particles'])
end

