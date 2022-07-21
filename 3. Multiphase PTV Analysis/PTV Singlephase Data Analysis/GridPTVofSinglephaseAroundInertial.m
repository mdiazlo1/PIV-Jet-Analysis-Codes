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
FPS = 10e6;


%% Load necessary data and obtain Run and Frame numbers

load([analyzeddirec '\LPTData.mat'],'vtracks','tracks')
load([analyzeddirec '\PTV_Singlephase.mat'])
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
        FramesInertial = tracks{Run}(ParticleNum).T;
        ParticleVelocityU = mean(vtracks{Run}(ParticleNum).U)*dperPix*FPS; %m/s
        ParticleVelocityV = mean(vtracks{Run}(ParticleNum).V)*dperPix*FPS; %m/s

        % Setting up bounds for this particle
        LeftBound = ceil(ParticleLocationX - Diameter/2 - D_HL*IntWinSize);
        RightBound = ceil(ParticleLocationX + Diameter/2+D_HR*IntWinSize);
        UpperBound = ceil(ParticleLocationY + Diameter/2+D_VUP*IntWinSize);
        LowerBound = ceil(ParticleLocationY - Diameter/2 - D_VD*IntWinSize);

        
            
        for i = 1:numel(FramesInertial)
            ParticleFrameInd = i;

            circlePixels = (rowsInImage - ParticleLocationY(ParticleFrameInd)).^2 ...
                + (columnsInImage - ParticleLocationX(ParticleFrameInd)).^2 <= (Diameter/2).^2; %Creating logical array size of final image with 1's where the particle is and 0's everywhere else


            [xgrid,ygrid] = meshgrid(LeftBound(ParticleFrameInd)+IntWinSize/2:IntWinSize:RightBound(ParticleFrameInd)-IntWinSize/2 ...
                , LowerBound(ParticleFrameInd)+IntWinSize/2:IntWinSize:UpperBound(ParticleFrameInd)-IntWinSize/2);

            Iterations = zeros(size(xgrid,1),size(xgrid,2));

            SumUInertial = zeros(size(xgrid,1),size(xgrid,2));
            SumVInertial = zeros(size(xgrid,1),size(xgrid,2));
            Iterations = zeros(size(xgrid,1),size(xgrid,2));
            UtoAverage = zeros(size(xgrid,1),size(xgrid,2));
            VtoAverage = zeros(size(xgrid,1),size(xgrid,2));

            for GasTrack = 1:numel(vtracksGas{Run})
                GasTrackFrame = vtracksGas{Run}(GasTrack).T;
                
                GasFrame = find(GasTrackFrame == FramesInertial(i));

                if isempty(GasFrame) 
                    continue
                end

                GasTrackX = vtracksGas{Run}(GasTrack).X(GasFrame); GasTrackY = vtracksGas{Run}(GasTrack).Y(GasFrame);
                GasTrackU = vtracksGas{Run}(GasTrack).U(GasFrame)*dperPix*FPS; GasTrackV = vtracksGas{Run}(GasTrack).V(GasFrame)*dperPix*FPS;

                if ~(GasTrackX>LeftBound(ParticleFrameInd) && GasTrackX<RightBound(ParticleFrameInd) && GasTrackY>LowerBound(ParticleFrameInd) && GasTrackY<UpperBound(ParticleFrameInd)) || GasTrackU<100
                    continue
                end
               
            
                [D_H,minXIn] = min(abs(xgrid(1,:)-GasTrackX)); [D_V,minYIn] = min(abs(ygrid(:,1)-GasTrackY));
                %Below if statement is for debugging purposes only
                if D_H > IntWinSize/2 || D_V > IntWinSize/2
                    disp(['ERROR: tracer particle' num2str(GasTrack) ' does not fit within an interrogation window'])
                end
                
                UtoAverage(minYIn,minXIn) = GasTrackU/(GasTrackU-ParticleVelocityU);
                VtoAverage(minYIn,minXIn) = GasTrackV/(GasTrackV - ParticleVelocityV);
                Iterations(minYIn,minXIn) = Iterations(minYIn,minXIn) + 1;
              
                SumUInertial(minYIn,minXIn) = SumUInertial(minYIn,minXIn) + UtoAverage(minYIn,minXIn);
                SumVInertial(minYIn,minXIn) = SumVInertial(minYIn,minXIn) + VtoAverage(minYIn,minXIn);
                

            end
            UInertial{Run}{i,m} = SumUInertial./Iterations;
            UInertial{Run}{i,m}(isnan(UInertial{Run}{i,m})) = 0; %Center (where particle is) will be NaN since you are dividing by 0 in above line in this region so replace NaN with 0 values

            VInertial{Run}{i,m} = SumVInertial./Iterations; %Renormalizing the velocities this is now you average
            VInertial{Run}{i,m}(isnan(VInertial{Run}{i,m})) = 0; %Center (where particle is) will be NaN since you are dividing by 0 in above line in this region so replace NaN with 0 values
        end


    end
end
save([analyzeddirec '\PTV_VelocityAroundInertialParticles.mat'], 'UInertial','VInertial',"IntWinSize","D_HL","D_VD","RightBound","LeftBound","UpperBound","LowerBound","Diameter")
