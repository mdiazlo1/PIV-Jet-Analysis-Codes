%% Directories
Tnum = 3;
datdirec = ['E:\PIV Data\Raw Data\2022_07_01\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_07_01\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_07_01\T' num2str(Tnum)];

% Plot settings
axiswidth = 2; linewidth = 2; fontsize = 18;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

ParticleDiameter = 139e-6;
dperPix = 6.625277859765377e-06;
FPS = 10e6;


%% Load necessary data and obtain Run and Frame numbers

load([analyzeddirec '\LPTData.mat'],'vtracks','tracks')
load([analyzeddirec '\PTV_Singlephase.mat'])
load([analyzeddirec '\InertialParticalSelection.mat'], 'tracksParticleIndex')

%% Setting up settings for interrogation window

IntWinSize = 4; %pixels %Getting the Interrogation window size of the PIV data
D_HL = ceil(48/IntWinSize);%Number of interrogation windows to the left; 12 for intwin 4
D_HR = ceil(96/IntWinSize); %Number of interrogation windows to the right; 24 for intwin 4
D_VUP = ceil(32/IntWinSize); %Number of inerrogation windows above the particle; 8 for intwin 4
D_VD = ceil(32/IntWinSize); %Number of interrogation; 8 for intwin 4
% Diameter = ceil(ParticleDiameter/dperPix) + 10;
Diameter = GetParticleDiameter(ParticleDiameter);
imageSizeX = 400+1; imageSizeY = 250+1;
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
%                 GasTrack = 110;
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
                
                UtoAverage(minYIdx,minXIdx) = GasTrackU/(GasTrackU-ParticleVelocityU);
                VtoAverage(minYIdx,minXIdx) = GasTrackV/(GasTrackV - ParticleVelocityV);
                Iterations(minYIdx,minXIdx) = Iterations(minYIdx,minXIdx) + 1;
              
                SumUInertial(minYIdx,minXIdx) = SumUInertial(minYIdx,minXIdx) + UtoAverage(minYIdx,minXIdx);
                SumVInertial(minYIdx,minXIdx) = SumVInertial(minYIdx,minXIdx) + VtoAverage(minYIdx,minXIdx);
                

            end
            UInertial{Run}{i,m} = SumUInertial./Iterations;
            UInertial{Run}{i,m}(isnan(UInertial{Run}{i,m})) = 0; %Center (where particle is) will be NaN since you are dividing by 0 in above line in this region so replace NaN with 0 values

            VInertial{Run}{i,m} = SumVInertial./Iterations; %Renormalizing the velocities this is now you average
            VInertial{Run}{i,m}(isnan(VInertial{Run}{i,m})) = 0; %Center (where particle is) will be NaN since you are dividing by 0 in above line in this region so replace NaN with 0 values
        end


    end
end

save([analyzeddirec '\PTV_VelocityAroundInertialParticles.mat'], 'UInertial','VInertial',"IntWinSize","D_HL","D_VD","RightBound","LeftBound","UpperBound","LowerBound","Diameter")


function Diameter = GetParticleDiameter(ParticleDiameter)

if ParticleDiameter == 200e-6
    Diameter = 60;
elseif ParticleDiameter == 139e-6
    Diameter = 45;

end
end

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