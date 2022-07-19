%% Setting up directories
Tnum = 5;
datdirec = ['E:\PIV Data\Raw Data\2022_07_01\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_07_01\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_07_01\T' num2str(Tnum)];

% Plot settings
axiswidth = 2; linewidth = 2; 
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

%% Analysis

addpath('.\Oulette codes\')
suffix = '*.tiff';
A = dir([processeddirec '\Tracer Particles\R*']); ProcessedRuns = {};
    [ProcessedRuns{1:length(A),1}] = A.name;
    ProcessedRuns = sortrows(ProcessedRuns)'; NumOfRuns = numel(ProcessedRuns); clear A

for k = 1:NumOfRuns
    disp(['Run ' num2str(k) ' of ' num2str(NumOfRuns)])
    [x{k},y{k},u{k},v{k},u_filt{k},v_filt{k}] = Miguel_PIVlab([processeddirec '\Tracer Particles' '\R' num2str(k) ], suffix,Mask);
clc;
end