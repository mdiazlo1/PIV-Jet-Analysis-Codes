%% Directories
Tnum = 7;
datdirec = ['D:\PIV Data\Raw Data\2022_06_28\T' num2str(Tnum)];
processeddirec = ['D:\PIV Data\Processed Data\2022_06_28\T' num2str(Tnum)];
analyzeddirec = ['D:\PIV Data\Analyzed Results\2022_06_28\T' num2str(Tnum)];

% Plot settings
axiswidth = 2; linewidth = 2; 
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

%% Parameters and Settings

% Parameters
dperPix = 6.625277859765377e-06;
FPS = 10e6; %10 millions frames per second

% Settings
GetMask = 0; %1 = yes, you still need to find the Mask, 0 = no, you dont need to get the mask again it's already set
Eliminateimages = 0; %if you still need to eliminate dark images
AdjustImageBrightness = 0;


% Obtaining run files
A = dir(datdirec); Runs = {};
[Runs{1:length(A),1}] = A.name;
Runs(strcmp(Runs,'.'))=[]; Runs(strcmp(Runs,'..'))=[];
Runs = sortrows(Runs); NumOfRuns = numel(Runs); clear A
datadirec = Runs;
%% Singlephase adjusting images

    % Using imhistmatch to match the histogram of the images and then
    % adjusting the image brightnesses so that they are similar brightness
    % (necessary for PIV)
    if Eliminateimages == 1
        EliminateDarkImages(datdirec,datadirec,processeddirec)
    end


    %Adjusting brightness of images by matching the histogram of all of the
    %images to the brightest image imhistmatch this function will also
    %create all of the necessary directories for future functions and image
    %processing
    if AdjustImageBrightness == 1
        AdjustingImageBrightness(datdirec,datadirec,processeddirec)
    end

%% PIV Analysis

if GetMask == 1
    Mask = DetermineMask([processeddirec '\HistMatchImages']);
    return
else
    Mask = [];
end

% addpath('.\PIVlab')
suffix = '*.tiff';

for k = 1:NumOfRuns
    disp(['Run ' num2str(k) ' of ' num2str(NumOfRuns)])
    [x{k},y{k},u{k},v{k},u_filt{k},v_filt{k}] = Miguel_PIVlab([processeddirec '\HistMatchImages' '\R' num2str(k) ], suffix,Mask);
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