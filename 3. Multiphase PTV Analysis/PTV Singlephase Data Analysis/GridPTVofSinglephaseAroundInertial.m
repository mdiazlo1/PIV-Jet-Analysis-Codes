%% Directories
Tnum = 3;
datdirec = ['E:\PIV Data\Raw Data\2022_06_30\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_06_30\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_06_30\T' num2str(Tnum)];
addpath(genpath('C:\Users\mxdni\OneDrive - Johns Hopkins\Plume-Surface Interaction Research Group\1. Projects\JET\5. Jet PIV\1. Matlab Codes\1. Newst PIV Code (June 2022)'))
% Plot settings
axiswidth = 2; linewidth = 2; fontsize = 18;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';


dperPix = 6.625277859765377e-06;
FPS = 10e6;
GridType = "Constant Diameter"; %Options are constant Diameter or deformable diameter
DiameterBuffer = 4;
%% Load necessary data and obtain Run and Frame numbers

load([analyzeddirec '\LPTData.mat'],'vtracks','tracks')
load([analyzeddirec '\PTV_Singlephase.mat'])
load([analyzeddirec '\InertialParticalSelection.mat'], 'ParticlesOfInterest','avgDiameter')

%% Setting up settings for interrogation window

IntWinSize = 8; %pixels %Getting the Interrogation window size of the PIV data

%Set up the ParticleDiam object and put filler numbers for ParticleLocation
%and Diameter for now
ParticleDiam = ParticleDiameter(GridType,DiameterBuffer,IntWinSize,avgDiameter,0,0,0);

imageSizeX = 400+1; imageSizeY = 250+1;
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

% Particle Information
for Run = 1:numel(ParticlesOfInterest)

    disp(['On Run ' num2str(Run) ' of ' num2str(numel(ParticlesOfInterest))])
    for m = 1:numel(ParticlesOfInterest{Run})


        ParticleNum = ParticlesOfInterest{Run}.ParticleNum(m);

        ParticleLocationX = tracks{Run}(ParticleNum).X; %Pix
        ParticleLocationY = tracks{Run}(ParticleNum).Y; %Pix
        FramesInertial = tracks{Run}(ParticleNum).T;
        ParticleVelocityU = mean(vtracks{Run}(ParticleNum).U)*dperPix*FPS; %m/s
        ParticleVelocityV = mean(vtracks{Run}(ParticleNum).V)*dperPix*FPS; %m/s
        
        %Use ParticleDiam object and methods to get bounds around particle
        ParticleDiam.DiameterOfParticle = ParticlesOfInterest{Run}.ParticleDiameter(m); 
        ParticleDiam.ParticleLocationX = ParticleLocationX; ParticleDiam.ParticleLocationY = ParticleLocationY;
        [LeftBound,RightBound,UpperBound,LowerBound,Diameter] = ParticleDiam.GridEdges();

        
            
        for i = 1:numel(FramesInertial)
            ParticleFrameIdx = i;

            circlePixels = (rowsInImage - ParticleLocationY(ParticleFrameIdx)).^2 ...
                + (columnsInImage - ParticleLocationX(ParticleFrameIdx)).^2 <= (Diameter/2).^2; %Creating logical array size of final image with 1's where the particle is and 0's everywhere else


            [xgrid,ygrid] = meshgrid(LeftBound(ParticleFrameIdx)+IntWinSize/2:IntWinSize:RightBound(ParticleFrameIdx)-IntWinSize/2 ...
                , LowerBound(ParticleFrameIdx)+IntWinSize/2:IntWinSize:UpperBound(ParticleFrameIdx)-IntWinSize/2);

            if ygrid(end,1) ~= UpperBound(ParticleFrameIdx)-IntWinSize/2
                ygrid(end+1,:) = repmat(UpperBound(ParticleFrameIdx)-IntWinSize/2,size(ygrid,2),1);
                ygrid(:,end+1) = ygrid(:,1);
            end
            if xgrid(1,end) ~= RightBound(ParticleFrameIdx)-IntWinSize/2
                xgrid(:,end+1) = repmat(RightBound(ParticleFrameIdx)-IntWinSize/2,size(xgrid,1),1);
                xgrid(end+1,:) = xgrid(1,:);
            end


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

                if ~(GasTrackX>LeftBound(ParticleFrameIdx) && GasTrackX<RightBound(ParticleFrameIdx) && GasTrackY>LowerBound(ParticleFrameIdx) && GasTrackY<UpperBound(ParticleFrameIdx)) || GasTrackU<100
                    continue
                end
               
            
                [D_H,minXIdx] = min(abs(xgrid(1,:)-GasTrackX)); [D_V,minYIdx] = min(abs(ygrid(:,1)-GasTrackY));
                %Below if statement is for debugging purposes only
                if D_H > IntWinSize/2 || D_V > IntWinSize/2
                    disp(['ERROR: tracer particle' num2str(GasTrack) ' does not fit within an interrogation window'])
                    return
                elseif ygrid(minYIdx,1) <= 0 || xgrid(1,minXIdx)<=0 || ygrid(minYIdx,1) > 250 || xgrid(1,minXIdx) > 400
                    continue
                elseif circlePixels(ceil(ygrid(minYIdx,1)+1),ceil(xgrid(1,minXIdx)+1))
                    [minYIdx,minXIdx] = FindNewMinimum(xgrid,ygrid,GasTrackX,GasTrackY,circlePixels,IntWinSize);
                    if minYIdx == 0
                        continue
                    end
                end
                
                UtoAverage(minYIdx,minXIdx) = GasTrackU;
                VtoAverage(minYIdx,minXIdx) = GasTrackV;
                Iterations(minYIdx,minXIdx) = Iterations(minYIdx,minXIdx) + 1;
              
                SumUInertial(minYIdx,minXIdx) = SumUInertial(minYIdx,minXIdx) + UtoAverage(minYIdx,minXIdx);
                SumVInertial(minYIdx,minXIdx) = SumVInertial(minYIdx,minXIdx) + VtoAverage(minYIdx,minXIdx);
                

            end
            NonNormalUInertial = SumUInertial./Iterations;
            NonNormalUInertial(NonNormalUInertial<=0) = NaN;

            avgUWindow = mean(NonNormalUInertial,'all','omitnan');
            UInertial{Run}{i,m} = (NonNormalUInertial-ParticleVelocityU)./(avgUWindow-ParticleVelocityU);
 
            NonNormalVInertial = SumVInertial./Iterations;
            NonNormalVInertial(NonNormalVInertial<=0) = NaN;

            avgVWindow = mean(NonNormalVInertial,'all','omitnan');
            VInertial{Run}{i,m} = (NonNormalVInertial-ParticleVelocityV)./(avgVWindow-ParticleVelocityV); %Center (where particle is) will be NaN since you are dividing by 0 in above line in this region so replace NaN with 0 values
        end


    end
end

save([analyzeddirec '\PTV_VelocityAroundInertialParticles.mat'], 'UInertial','VInertial',"IntWinSize","RightBound","LeftBound","UpperBound","LowerBound","Diameter")


function [minYIdx,minXIdx] = FindNewMinimum(xgrid,ygrid,GasTrackX,GasTrackY,circlePixels,IntWinSize)
    XDifference = abs(xgrid(1,:)-GasTrackX);
    YDifference = abs(ygrid(:,1)-GasTrackY);

    XDifference = sort(XDifference); YDifference = sort(YDifference); i = 1;
    while(1)
        i = i + 1;
        if i > numel(XDifference) || XDifference(i) > 3*IntWinSize || YDifference(i) > 3*IntWinSize
            minXIdx = 0; minYIdx = 0;
            break
        end
        NewMinXDiff = XDifference(i); NewMinYDiff = YDifference(i);
        
        NewMinXIdx = find(abs(xgrid(1,:)-GasTrackX)==NewMinXDiff,1);
        NewMinYIdx = find(abs(ygrid(:,1)-GasTrackY)==NewMinYDiff,1);

        if ygrid(NewMinYIdx,1) <= 0 || xgrid(1,NewMinXIdx)<=0 || ygrid(NewMinYIdx,1) > 250 || xgrid(1,NewMinXIdx) > 400
            continue
        elseif ~circlePixels(ceil(ygrid(NewMinYIdx,1)+1),ceil(xgrid(1,NewMinXIdx)+1))
            minXIdx = NewMinXIdx; minYIdx = NewMinYIdx;
            break
        end
    end

end