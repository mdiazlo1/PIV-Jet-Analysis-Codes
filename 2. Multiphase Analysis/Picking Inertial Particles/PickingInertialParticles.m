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
% load([analyzeddirec '\ParticleStats.mat'])
load([analyzeddirec '\LPTData.mat'])

for Run = 1:1
    disp(['On Run = ' num2str(Run) ' of ' num2str(NumOfRuns)])

    Frame = vtracks{Run}(1).T(1);

     A = dir([processeddirec '\Inertial Particles\R' num2str(Run) '\*.tiff']); ImageDirec = {};
    [ImageDirec{1:length(A),1}] = A.name;
    ImageDirec = sortrows(ImageDirec); NumOfRuns = numel(ImageDirec); clear A
    temp = imread([processeddirec '\Inertial Particles\R' num2str(Run) filesep ImageDirec{Frame}]);

    
    XLocations = zeros(1,numel(tracks{Run})); YLocations = zeros(1,numel(tracks{Run}));
    for i = 1:numel(tracks{Run})
        Index = find(tracks{Run}(i).T == Frame);
        if numel(tracks{Run})~=numel(vtracks{Run})
            disp('ERROR: Houston, we have a problem.')
            return
        end
        XLocations(i) = tracks{Run}(i).X(Index);
        YLocations(i) = tracks{Run}(i).Y(Index);
    end
    

    % Pick data
    hFig = figure;
    imshow(temp)
    hold on

    hPlot = scatter(XLocations,YLocations,'blue','filled');
   
    % create and enable the brush object
    
    title("Hold shift and select all particles of interest then close the window to finish",'FontName','Times New Roman')
    PrettyFigures(linewidth,fontsize,axiswidth)
    hFig.Position = [519,233,1.5e+03,10e+02];

    [XData,YData] = DataPicker(hFig,hPlot);
end
    
   


