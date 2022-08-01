%% Directories
direc = DirectoryAssignment('E:\PIV Data','2022_06_22',3,0,0);

[~,processeddirec,analyzeddirec] = direc.GeneratePaths();

% Plot settings
axiswidth = 2; linewidth = 2; 
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

sharpen = 1;
binarize = 0;
adjustlow = 0.2;
%% Sharpen image to individual particles are easier to see
if sharpen == 1
    A = dir([processeddirec '\Tracer Particles\R*']); ProcessedRuns = {};
    [ProcessedRuns{1:length(A),1}] = A.name;
    ProcessedRuns = sortrows(ProcessedRuns)'; NumOfRuns = numel(ProcessedRuns); clear A
    for k = 1:NumOfRuns
        inputnames = [processeddirec '\Tracer Particles' '\R' num2str(k)];
        A = dir([inputnames '\*.tiff']); Image = {};
        [Image{1:length(A),1}] = A.name;
        Images = sortrows(Image)'; clear A

        for i = 1:numel(Images)
            temp = imread([inputnames '\' Images{i}]);
            tempadjust = imadjust(temp,[adjustlow,1]);
            tempSharpen = imsharpen(temp,'Amount',1.2,'Radius',1,'Threshold',0);

            if ~exist([processeddirec '\Sharpened Tracer Particles\R' num2str(k)],'dir')
                mkdir([processeddirec '\Sharpened Tracer Particles\R' num2str(k)])
            end
        

            imwrite(tempSharpen,[processeddirec '\Sharpened Tracer Particles\R' num2str(k) filesep Images{i}])
        end
    end
end

if binarize == 1
        A = dir([processeddirec '\Tracer Particles\R*']); ProcessedRuns = {};
    [ProcessedRuns{1:length(A),1}] = A.name;
    ProcessedRuns = sortrows(ProcessedRuns)'; NumOfRuns = numel(ProcessedRuns); clear A
    for k = 1:NumOfRuns
        inputnames = [processeddirec '\Tracer Particles' '\R' num2str(k)];
        A = dir([inputnames '\*.tiff']); Image = {};
        [Image{1:length(A),1}] = A.name;
        Images = sortrows(Image)'; clear A

        for i = 1:numel(Images)
            temp = imread([inputnames '\' Images{i}]);
            im_bin = imbinarize(temp,'adaptive');
            alg = 2*floor(size(temp,1)/16)+1;
            a = adaptthresh(temp,0.5,'NeighborhoodSize',alg-26,'Statistic','mean');
            
            im_bin2 = imbinarize(temp,a);

            if ~exist([processeddirec '\AdaptBinarize Sharpen Tracers\R' num2str(k)],'dir')
                mkdir([processeddirec '\AdaptBinarize Sharpen Tracers\R' num2str(k)])
            end
        

            imwrite(im_bin2,[processeddirec '\AdaptBinarize Sharpen Tracers\R' num2str(k) filesep Images{i}])
        end
    end
end

%% Analysis

Threshold = 40000;
area_lim = [2 30];
dperPix = 6.625277859765377e-06;
max_disp = 10;

addpath('.\Oulette codes\')
suffix = '*.tiff';
A = dir([processeddirec '\Sharpened Tracer Particles\R*']); ProcessedRuns = {};
    [ProcessedRuns{1:length(A),1}] = A.name;
    ProcessedRuns = sortrows(ProcessedRuns)'; NumOfRuns = numel(ProcessedRuns); clear A
m = 0;
for k = 1:NumOfRuns
%     disp(['Run ' num2str(k) ' of ' num2str(NumOfRuns)])
    inputnames = [processeddirec '\Sharpened Tracer Particles' '\R' num2str(k) '\*.tiff'];
    A = dir(inputnames); ImageNum = {};
    [ImageNum{1:length(A),1}] = A.name;
    ImageNum = sortrows(ImageNum)'; clear A

    if numel(ImageNum)>=7
        m = m+1;
        [vtracksGas{k},ntracks{k},meanlength{k},rmslength{k},tracksGas{k}] = PredictiveTracker(inputnames,Threshold,max_disp,[],area_lim,0,0);
    end
% clc;
end


save([analyzeddirec '\PTV_Singlephase.mat'],'vtracksGas','tracksGas')