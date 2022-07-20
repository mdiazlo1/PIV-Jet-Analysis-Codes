%% Directories
Tnum = 3;
datdirec = ['D:\PIV Data\Raw Data\2022_06_30\T' num2str(Tnum)];
processeddirec = ['D:\PIV Data\Processed Data\2022_06_30\T' num2str(Tnum)];
analyzeddirec = ['D:\PIV Data\Analyzed Results\2022_06_30\T' num2str(Tnum)];

% Plot settings
axiswidth = 2; linewidth = 2; 
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

sharpen = 1;

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

            tempSharpen = imsharpen(temp,'Amount',1.2,'Radius',1,'Threshold',0);

            if ~exist([processeddirec '\Sharpened Tracer Particles\R' num2str(k)],'dir')
                mkdir([processeddirec '\Sharpened Tracer Particles\R' num2str(k)])
            end
        

            imwrite(tempSharpen,[processeddirec '\Sharpened Tracer Particles\R' num2str(k) filesep Images{i}])
        end
    end
    
end

%% Analysis

Threshold = 50000;
area_lim = 1;
dperPix = 6.625277859765377e-06;
max_disp = 12;

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
        [vtracksGas{m},ntracks{m},meanlength{m},rmslength{m},tracksGas{m}] = PredictiveTracker(inputnames,Threshold,max_disp,[],area_lim,0,0);
    end
% clc;
end


save([analyzeddirec '\PTV_Singlephase.mat'],'vtracksGas','tracksGas')