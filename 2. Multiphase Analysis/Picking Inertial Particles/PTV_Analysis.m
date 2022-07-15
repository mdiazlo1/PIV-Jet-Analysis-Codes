%% Directories
Tnum = 5;
datdirec = ['E:\PIV Data\Raw Data\2022_07_01\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_07_01\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_07_01\T' num2str(Tnum)];
addpath("Oulette codes\")
% Plot settings
axiswidth = 2; linewidth = 2; 
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

particleDiameter = 137.5e-6;
dperPix = 6.625277859765377e-06;
PixelParticleDiameter = particleDiameter/dperPix;

LowerDiameterPixelBuffer = 20;
UpperDiameterPixelBuffer = 100;
%% Getting particle settings for Oullette's code

area_large_particle = pi/4*(PixelParticleDiameter+UpperDiameterPixelBuffer)^2;
smallarea_large_particle = pi/4*(PixelParticleDiameter-LowerDiameterPixelBuffer)^2;
area_lim = [smallarea_large_particle area_large_particle];
threshold = 65535;

A = dir([processeddirec '\Inertial Particles\R*']); ProcessedRuns = {};
    [ProcessedRuns{1:length(A),1}] = A.name;
    ProcessedRuns = sortrows(ProcessedRuns); NumOfRuns = numel(ProcessedRuns); clear A

for i = 1:NumOfRuns
    direc = [processeddirec '\Inertial Particles\R' num2str(i) '\*.tiff'];
    [vtracks{i},ntracks,meanlength,rmslength] = PredictiveTracker(direc,20,10,[],area_lim,0,0);
end


save([analyzeddirec '\LPTData.mat'],"vtracks")

%% Plotting Particle centroids found by Oullette's code with Binary images

% Run = 1;
% Frame = 5;
% 
% temp = imread([processeddirec '\Inertial Particles\R' num2str(Run) '\data_' sprintf( '%03d', Frame) '.tiff']);
% figure
% imshow(temp)
% hold on
% for m = 1:numel(vtracks{Run})
%     scatter(vtracks{Run}(m).X(1),vtracks{Run}(m).Y(1),40,'red','filled')
% end







