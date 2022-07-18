%% Directories
close all
Tnum = 5;
datdirec = ['E:\PIV Data\Raw Data\2022_07_01\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_07_01\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_07_01\T' num2str(Tnum)];
addpath("Oulette codes\")
% Plot settings
axiswidth = 2; linewidth = 2;  fontsize = 12;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

 A = dir([processeddirec '\Inertial Particles\R*']); ProcessedRuns = {};
    [ProcessedRuns{1:length(A),1}] = A.name;
    ProcessedRuns = sortrows(ProcessedRuns); NumOfRuns = numel(ProcessedRuns); clear A
%% Plotting raw image with found LPT track for each run
load([analyzeddirec '\ParticleStats.mat'])
load([analyzeddirec '\LPTData.mat'])



for Run = 1:1
   
    disp(['On Run = ' num2str(Run) ' of ' num2str(NumOfRuns)])
    A = dir([processeddirec '\Inertial Particles\R' num2str(Run) '\*.tiff']);ImageDirec = {};
    [ImageDirec{1:length(A),1}] = A.name;
    ImageDirec = sortrows(ImageDirec); clear A
    Index = ceil(numel(ImageDirec)/2); 

    temp = imread([processeddirec '\Inertial Particles\R' num2str(Run) filesep ImageDirec{Index}]);

    % Pick data
    
    hFig = figure;
    imshow(temp)
    hold on
    
    % create and enable the brush object
    hPlot = scatter(ParticleCenters{Run}{Index}(:,1),ParticleCenters{Run}{Index}(:,2),40,'blue','filled');
    title("Hold shift and select all particles of interest then close the window to finish",'FontName','Times New Roman')
    PrettyFigures(linewidth,fontsize,axiswidth)
    hFig.Position = [519,233,1.5e+03,10e+02];

    [XData,YData] = DataPicker(hFig,hPlot);

end
    
   


