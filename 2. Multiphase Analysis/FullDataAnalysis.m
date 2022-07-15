%% Directories
Tnum = 5;
datdirec = ['E:\PIV Data\Raw Data\2022_07_01\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_07_01\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_07_01\T' num2str(Tnum)];

% Plot settings
axiswidth = 2; linewidth = 2; 
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

%% Parameters and Settings

% Parameters
ParticleDiameter = 29.5e-6;
dperPix = 6.625277859765377e-06;
FPS = 10e6; %10 millions frames per second

% Settings
Segmentation = 1; %1 = yes, you need segmentation since processed images haven't been generated yet. 0 = No, processed images already generated
GetMask = 0; %1 = yes, you still need to find the Mask, 0 = no, you dont need to get the mask again it's already set
EliminateImages = 1;

% Obtaining run files
A = dir(datdirec); Runs = {};
[Runs{1:length(A),1}] = A.name;
Runs(strcmp(Runs,'.'))=[]; Runs(strcmp(Runs,'..'))=[];
Runs = sortrows(Runs); NumOfRuns = numel(Runs); clear A

for i = 1:NumOfRuns
    A = dir([datdirec '\R' num2str(i) '\Camera_*']); datadirec{i,1} = {};
    [datadirec{i,1}{1:length(A),1}] = A.name;
    datadirec{i,1}(strcmp(datadirec{i},'.'))=[]; datadirec{i,1}(strcmp(datadirec{i,1},'..'))=[];
    datadirec{i,1} = sortrows(datadirec{i})'; clear A
end

%% Multiphase Image Segmentation

    % Using imhistmatch to match the histogram of the images and then
    % adjusting the image brightnesses so that they are similar brightness
    % (necessary for PIV)
    if EliminateImages == 1
        EliminateDarkImages(datdirec,datadirec,processeddirec)
    end


    %Adjusting brightness of images by matching the histogram of all of the
    %images to the brightest image imhistmatch this function will also
    %create all of the necessary directories for future functions and image
    %processing
    AdjustingImageBrightness(datdirec,datadirec,processeddirec)
    
    %This part of the code will segment the images between inertial
    %particles and tracer particles. 
    ImageSegmentation(processeddirec,analyzeddirec,dperPix, ParticleDiameter)



%% PIV Analysis of tracer particles
if GetMask == 1
    Mask = DetermineMask([processeddirec '\Tracer Particles']);
    return
end
% else
%     Mask = [];
% end

addpath('.\PIVlab')
suffix = '*.tiff';
A = dir([processeddirec '\Tracer Particles\R*']); ProcessedRuns{i,1} = {};
    [ProcessedRuns{1:length(A),1}] = A.name;
    ProcessedRuns{i,1} = sortrows(ProcessedRuns{i})'; NumOfRuns = numel(ProcessedRuns); clear A

for k = 1:NumOfRuns
    disp(['Run ' num2str(k) ' of ' num2str(NumOfRuns)])
    [x{k},y{k},u{k},v{k},u_filt{k},v_filt{k}] = Miguel_PIVlab([processeddirec '\Tracer Particles' '\R' num2str(k) ], suffix,Mask);
clc;
end

%% Calibration
for k = 1:size(x,2)
    for j = 1:size(x{1,k},1)
        xcal{1,k}{j,1} = x{1,k}{j,1}*dperPix;
        ycal{1,k}{j,1} = y{1,k}{j,1}*dperPix;

        ucal{1,k}{j,1} = u{1,k}{j,1}*dperPix*FPS;
        vcal{1,k}{j,1} = v{1,k}{j,1}*dperPix*FPS;

        u_filtcal{1,k}{j,1} = u{1,k}{j,1}*dperPix*FPS;
        v_filtcal{1,k}{j,1} = v{1,k}{j,1}*dperPix*FPS;
    end
end


if ~exist(analyzeddirec, 'dir')
      mkdir(analyzeddirec)
end
save([analyzeddirec '\PIVData.mat'],'xcal','ycal','ucal','vcal','u_filtcal','v_filtcal' ...
    ,'x','y','u','v','u_filt','v_filt','dperPix','FPS')






