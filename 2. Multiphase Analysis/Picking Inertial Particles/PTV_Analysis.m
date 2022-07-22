%% Directories
Tnum = 3;
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

NeedParticleTracks = 1; %If you need to do lagrangian particle tracking
NeedParticleStatistics = 1; %If you just need particle centroids and radii
%% Setting Parameters
 A = dir([processeddirec '\Inertial Particles\R*']); ProcessedRuns = {};
    [ProcessedRuns{1:length(A),1}] = A.name;
    ProcessedRuns = sortrows(ProcessedRuns); NumOfRuns = numel(ProcessedRuns); clear A

    area_large_particle = pi/4*(PixelParticleDiameter+UpperDiameterPixelBuffer)^2;
    smallarea_large_particle = pi/4*(PixelParticleDiameter-LowerDiameterPixelBuffer)^2;
    area_lim = [smallarea_large_particle area_large_particle];
%% Getting particle settings for Oullette's code
if NeedParticleTracks
    
    threshold = 65535;
m = 0;

    for i = 1:NumOfRuns
        direc = [processeddirec '\Inertial Particles\R' num2str(i) '\*.tiff'];

        A = dir(direc); ImageNum = {};
        [ImageNum{1:length(A),1}] = A.name;
        ImageNum = sortrows(ImageNum)'; clear A

        if numel(ImageNum)>=7
            m = m+1;
            [vtracks{i},ntracks,meanlength,rmslength,tracks{i}] = PredictiveTracker(direc,20,10,[],area_lim,0,0);
        end

    end


    save([analyzeddirec '\LPTData.mat'],"vtracks","tracks")
end
%% Plotting Particle centroids found by Oullette's code with Binary images
% if NeedParticleStatistics
%     for i = 1:NumOfRuns
%         disp(['On Run = ' num2str(i) ' of ' num2str(NumOfRuns)])
%         A = dir([processeddirec '\Inertial Particles\R' num2str(i) '\*.tiff']);ImageDirec = {};
%         [ImageDirec{1:length(A),1}] = A.name;
%         ImageDirec = sortrows(ImageDirec); clear A
% 
%         for j = 1:numel(ImageDirec)
%             temp = imbinarize(imread([processeddirec '\Inertial Particles\R' num2str(i) filesep ImageDirec{j}]));
%             remove_small = bwareafilt(temp,area_lim);
%             stats = regionprops('table',temp,'Centroid','MajorAxisLength'...
%                 ,'MinorAxisLength','Area');
%             
%             pos=vertcat(stats.Centroid);
%             s = size(temp);
%             if numel(pos)>0
%                 good = pos(:,1)~=1 & pos(:,2)~=1 & pos(:,1)~=s(2) & ...
%                     pos(:,2)~=s(1) & vertcat(stats.Area)>area_lim(1) & ...
%                     vertcat(stats.Area)<area_lim(2); % remove regions on edge, too small, or too big
%                 pos=pos(good,:);
%                 stats=stats(good,:);
%             end
%             centers = stats.Centroid;
%             ParticleCenters{i,1}{j,1} = centers;
%             diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
%             ParticleRadii{i,1}{j,1} = diameters/2; radii = diameters/2;
%         end
%     end
% end

% for Run = 1:NumOfRuns
%     direc = [processeddirec '\Inertial Particles\R' num2str(Run) '\data_001.tiff'];
%     [x{Run},y{Run},T{Run},~]=ParticleFinder(direc,20,[],[],[],area_lim,0,0);
% end




%% Organize Centroid and Radii data into tracks



% save([analyzeddirec '\ParticleStats.mat'],'ParticleCenters','ParticleRadii')






