%% Directories
direc = DirectoryAssignment('E:\PIV Data','2022_06_23',3,0,0);

[~,processeddirec,analyzeddirec] = direc.GeneratePaths();

% Plot settings
axiswidth = 2; linewidth = 2; fontsize = 18;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

ParticleDiameter = 200e-6;
dperPix = 6.625277859765377e-06;


%% Load necessary data and obtain Run and Frame numbers

load([analyzeddirec '\PTV_Singlephase.mat'])

Run = 1;


inputnames = [processeddirec '\Inertial Particles' '\R' num2str(Run)];
A = dir([inputnames '\*.tiff']); Image = {};
[Image{1:length(A),1}] = A.name;
Images = sortrows(Image)'; clear A

for i = 1:numel(Images)
    Img(:,:,i) = imread([inputnames '\' Images{i}]);
end


for i = 1:size(Img,3)
    vec_im(i).matrix = Img(:,:,i);
end

% Calculates maximum of next frame and current frame
for j = 1:numel(vec_im)

    if j == 1
    
        new_max = max(vec_im(j).matrix,vec_im(j+1).matrix); % Obtain the maximum of the two frames
        new_max_vec(j).new_max = new_max; % New max vector


    elseif j == numel(vec_im)
        
        
    else
        
        new_max = max(vec_im(j+1).matrix,new_max_vec(j-1).new_max); % Obtain the maximum of the two frames
        new_max_vec(j).new_max = new_max; % New max vector    
    end
end

% for i = 1:numel()
%     AllParticleLocationsX{i} = vtracksGas(i).X;
%     AllParticleLocationsY{i} = vtracksGas(i).Y;
% 
%     AllParticleFrames{i} = vtracksGas(i).T;
% end



f = figure('visible','on'); % Change to off once you know it's working

count = 0;
% if ~exist([NewImage_dir 'T' num2str(Tnum) '\R' num2str(Run) '\C2\OverExposed Image\'  ],'dir')
%     mkdir([NewImage_dir 'T' num2str(Tnum) '\R' num2str(Run) '\C2\OverExposed Image\'])
% end
% Generates new image and saves to specified directory
ParticleTracks = 0;
for ii = 1:numel(new_max_vec)
    
    new_im = uint16(new_max_vec(ii).new_max);
%     new_im = imlocalbrighten(new_im,0.2); % I did not need this but can
%     be used to brighten image
    
    [ParticleTracks] = GetParticleLocations(vtracksGas{Run},ii,ParticleTracks);
    if ParticleTracks == 0
        continue
    end
    imshow(new_im)
    hold on
    scatter(ParticleTracks(:,1),ParticleTracks(:,2),10,'red','filled')
    hold off
    pause(0.5)
%     imwrite(new_im,[NewImage_dir 'T' num2str(Tnum) '\R' num2str(Run) '\C2\OverExposed Image\data_' num2str(count) '.tif' ]) % Save new frame
    count = count+1;
  
end

function [ParticleTracks] = GetParticleLocations(vtracksGas,ii,ParticleTracks)
m = 0; 

for i = 1:numel(vtracksGas)
    frame = vtracksGas(i).T;

    SameFrame = find(frame==ii);
    if ~isempty(SameFrame)
        m = m+1;
        ParticleTracksConcat(m,1) = vtracksGas(i).X(SameFrame);
        ParticleTracksConcat(m,2) = vtracksGas(i).Y(SameFrame);
    end
end
if ~exist('ParticleTracksConcat',"var")
    return
elseif ParticleTracks == 0
    ParticleTracks = ParticleTracksConcat;
else
    ParticleTracks = vertcat(ParticleTracks,ParticleTracksConcat);
end



end