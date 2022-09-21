%% Directories
Tnum = 6; Run = 1;
direc = DirectoryAssignment('E:\PIV Data','2022_07_01',Tnum,Run,0);
[~,processeddirec,analyzeddirec] = direc.GeneratePaths();

% Plot settings
axiswidth = 2; linewidth = 2; fontsize = 18;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';



%% Load necessary data and obtain Run and Frame numbers

load([analyzeddirec '\LPTData.mat'],'vtracks','tracks')

load([analyzeddirec '\InertialParticalSelection.mat'], 'ParticlesOfInterest','avgDiameter')




