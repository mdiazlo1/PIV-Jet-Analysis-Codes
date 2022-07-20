%% Directories
Tnum = 3;
datdirec = ['E:\PIV Data\Raw Data\2022_06_30\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_06_30\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_06_30\T' num2str(Tnum)];

% Plot settings
axiswidth = 2; linewidth = 2; fontsize = 18;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

ParticleDiameter = 200e-6;
dperPix = 6.625277859765377e-06;


%% Load necessary data and obtain Run and Frame numbers

load([analyzeddirec '\LPTData.mat'],'vtracks','tracks')
load([analyzeddirec '\PIVData.mat'])
load([analyzeddirec '\InertialParticalSelection.mat'], 'tracksParticleIndex')

%% Setting up settings for interrogation window

IntWinSize = 4; %pixels %Getting the Interrogation window size of the PIV data
D_HL = 12;%Number of interrogation windows to the left
D_HR = 24; %Number of interrogation windows to the right
D_VUP = 8; %Number of inerrogation windows above the particle
D_VD = 8; %Number of interrogation
% Diameter = ceil(ParticleDiameter/dperPix) + 10;
Diameter = 60;
imageSizeX = 450; imageSizeY = 250;
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

% Particle Information
for Run = 1:numel(tracksParticleIndex)
     disp(['On Run ' num2str(Run) ' of ' num2str(numel(tracksParticleIndex))])
    for m = 1:numel(tracksParticleIndex{Run})


        ParticleNum = tracksParticleIndex{Run}(m);

        ParticleLocationX = tracks{Run}(ParticleNum).X; %Pix
        ParticleLocationY = tracks{Run}(ParticleNum).Y; %Pix
        Frames = vtracks{Run}(ParticleNum).T;
        ParticleVelocityU = mean(vtracks{Run}(ParticleNum).U)*dperPix*FPS; %m/s
        ParticleVelocityV = mean(vtracks{Run}(ParticleNum).V)*dperPix*FPS; %m/s

        % Setting up bounds for this particle
        LeftBound = ceil(ParticleLocationX - Diameter/2 - D_HL*IntWinSize);
        RightBound = ceil(ParticleLocationX + Diameter/2+D_HR*IntWinSize);
        UpperBound = ceil(ParticleLocationY + Diameter/2+D_VUP*IntWinSize);
        LowerBound = ceil(ParticleLocationY - Diameter/2 - D_VD*IntWinSize);

        for i = 1:numel(Frames)
            Frame = i;
    

            circlePixels = (rowsInImage - ParticleLocationY(Frame)).^2 + (columnsInImage - ParticleLocationX(Frame)).^2 <= (Diameter/2).^2; %Creating logical array size of final image with 1's where the particle is and 0's everywhere else

            [xgrid,ygrid] = meshgrid(LeftBound:IntWinSize:RightBound, LowerBound:IntWinSize:UpperBound);
            SumUInertial = zeros(size(xgrid,1),size(xgrid,2));
            SumVInertial = zeros(size(xgrid,1),size(xgrid,2));
            Iterations = zeros(size(xgrid,1),size(xgrid,2));
            WeightScale = zeros(size(xgrid,1),size(xgrid,2));





        end


    end
end