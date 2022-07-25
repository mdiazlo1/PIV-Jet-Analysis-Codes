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

%Decide if you want to define grid based off of Particle center and grid
%doesn't change size no matter the particle diameter (particle diameter
%changes) or if you want to set a constant particle diameter that all of
%the grids are based off of
GridType = "Deformable Diameter"; %Options are constant Diameter or deformable diameter

DiameterBuffer = 4; %How many pixels to add to the calculated diameter from regionprops
%% Load necessary data and obtain Run and Frame numbers

load([analyzeddirec '\LPTData.mat'],'vtracks','tracks')
load([analyzeddirec '\PIVData.mat'])
load([analyzeddirec '\InertialParticalSelection.mat'], 'ParticlesOfInterest','avgDiameter')

%% Setting up settings for interrogation window

IntWinSize = (x{1,1}{1,1}(1,2)-x{1,1}{1,1}(1,1)); %pixels %Getting the Interrogation window size of the PIV data
IntWinSize = 4;
switch GridType
    case 'Constant Diameter'
        D_HL = ceil(48/IntWinSize);%Number of interrogation windows to the left; 12 for intwin 4
        D_HR = ceil(56/IntWinSize); %Number of interrogation windows to the right; 24 for intwin 4
        D_VUP = ceil(32/IntWinSize); %Number of inerrogation windows above the particle; 8 for intwin 4
        D_VD = ceil(32/IntWinSize); %Number of interrogation; 8 for intwin 4
    case 'Deformable Diameter'
        
        D_HL = ceil((28+avgDiameter + DiameterBuffer)/IntWinSize);%Number of interrogation windows to the left; 12 for intwin 4
        D_HR = ceil((36+avgDiameter + DiameterBuffer)/IntWinSize); %Number of interrogation windows to the right; 24 for intwin 4
        D_VUP = ceil((12+avgDiameter + DiameterBuffer)/IntWinSize); %Number of inerrogation windows above the particle; 8 for intwin 4
        D_VD = ceil((12+avgDiameter + DiameterBuffer)/IntWinSize); %Number of interrogation; 8 for intwin 4
end
% Diameter = GetParticleDiameter(ParticleDiameter);

imageSizeX = 400+1; imageSizeY = 250+1;
[columnsInImage, rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

% Particle Information
for Run = 1:numel(ParticlesOfInterest)
     disp(['On Run ' num2str(Run) ' of ' num2str(numel(ParticlesOfInterest))])
    for m = 1:numel(ParticlesOfInterest{Run})


        ParticleNum = ParticlesOfInterest{Run}.ParticleNum(m);
        

        ParticleLocationX = tracks{Run}(ParticleNum).X; %Pix
        ParticleLocationY = tracks{Run}(ParticleNum).Y; %Pix
        ParticleInertialFrame = tracks{Run}(ParticleNum).T;
        ParticleVelocityU = mean(vtracks{Run}(ParticleNum).U)*dperPix*FPS; %m/s
        ParticleVelocityV = mean(vtracks{Run}(ParticleNum).V)*dperPix*FPS; %m/s
        

        % Setting up bounds for this particle
        switch GridType
            case 'Constant Diameter'
                Diameter = avgDiameter+DiameterBuffer; %pix
                LeftBound = ceil(ParticleLocationX - Diameter/2 - D_HL*IntWinSize);
                RightBound = ceil(ParticleLocationX + Diameter/2+D_HR*IntWinSize);
                UpperBound = ceil(ParticleLocationY + Diameter/2+D_VUP*IntWinSize);
                LowerBound = ceil(ParticleLocationY - Diameter/2 - D_VD*IntWinSize);
            case 'Deformable Diameter'
                Diameter = ParticlesOfInterest{Run}.ParticleDiameter(m)+DiameterBuffer; %pix
                LeftBound = ceil(ParticleLocationX - D_HL*IntWinSize);
                RightBound = ceil(ParticleLocationX+D_HR*IntWinSize);
                UpperBound = ceil(ParticleLocationY+D_VUP*IntWinSize);
                LowerBound = ceil(ParticleLocationY - D_VD*IntWinSize);
        end
        for FrameIdx = 1:numel(ParticleLocationX)
            if ParticleInertialFrame(FrameIdx)>numel(ucal{Run})
                continue
            end
            GasFrame = ParticleInertialFrame(FrameIdx);

            circlePixels = (rowsInImage - ParticleLocationY(FrameIdx)).^2 + (columnsInImage - ParticleLocationX(FrameIdx)).^2 <= (Diameter/2).^2; %Creating logical array size of final image with 1's where the particle is and 0's everywhere else
%             circlePixels = flip(circlePixels,1);
            [xgrid,ygrid] = meshgrid(LeftBound(FrameIdx)+IntWinSize/2:IntWinSize:RightBound(FrameIdx)-IntWinSize/2 ...
                , LowerBound(FrameIdx)+IntWinSize/2:IntWinSize:UpperBound(FrameIdx)-IntWinSize/2);
          
            SumUInertial = zeros(size(xgrid,1),size(xgrid,2));
            SumVInertial = zeros(size(xgrid,1),size(xgrid,2));
            Iterations = zeros(size(xgrid,1),size(xgrid,2));
            WeightScale = zeros(size(xgrid,1),size(xgrid,2));


            [row, col] = find(x{Run}{GasFrame} > LeftBound(FrameIdx) & x{Run}{GasFrame} < RightBound(FrameIdx) ...
                & y{Run}{GasFrame} < UpperBound(FrameIdx) & y{Run}{GasFrame} > LowerBound(FrameIdx));

            xGasData = x{Run}{GasFrame}(min(row):max(row),min(col):max(col));
            yGasData = y{Run}{GasFrame}(min(row):max(row),min(col):max(col));
            uGasData = ucal{Run}{GasFrame}(min(row):max(row),min(col):max(col));
            vGasData = vcal{Run}{GasFrame}(min(row):max(row),min(col):max(col));
            AverageGasPhaseU = mean(uGasData,'all','omitnan');
            AverageGasPhaseV = mean(vGasData,'all','omitnan');
            
            for i = 1:size(xGasData,2) %loop through all x values of the data grid
                
                xdata = xGasData(1,i); %determine x values from data grid

                for j = 1:size(xGasData,1) %Loop through all y values of the data grid
                    ydata = yGasData(j,1); %determine y values from data grid
                        if ~circlePixels(ydata,xdata) %Ensures that we don't account for data that is within the particle radius of the final grid.
                            UtoAverage = zeros(size(xgrid,1),size(xgrid,2));
                            VtoAverage = zeros(size(xgrid,1),size(xgrid,2));
                            for k = 1:size(xgrid,2) %Loop through the new made up grid x values
                                D_H = abs(xdata-xgrid(1,k)); %Obtain the horizontal distance between the data x value and the made up grid x value

                                for p = 1:size(xgrid,1) %Loop through the new made up grid y values
                                    D_V = abs(ydata - ygrid(p,1)); %Obtain the vertical distance between the data y value and the made up grid y value
                                    
                                    if ygrid(p,1) <= 0 || xgrid(1,k)<=0 || ygrid(p,1) > 250 || xgrid(1,k) > 400
                                        continue
                                    end
                                    if D_H < IntWinSize && D_V < IntWinSize &&  ~circlePixels(ygrid(p,1),xgrid(1,k)) && uGasData(j,i) > 0%Check to see if the data grid box is overlapping with the made up grid box
                                        Xoverlap = IntWinSize - D_H; %obtain the amount of overlap in x distance
                                        Yoverlap = IntWinSize - D_V; %obtain the amount of overlap of in y distance

                                        AreaOverlap = Xoverlap*Yoverlap; %Calculate the area of the shaded region
                                        Weight = AreaOverlap/(IntWinSize^2); %Obtain the percentage of the overlap region that makes up the total area of the interogation window this will be our averaging weight

                                        UtoAverage(p,k) = Weight*(uGasData(j,i)-ParticleVelocityU)/abs(AverageGasPhaseU - ParticleVelocityU); %Applying the weight to the averaging (will be renormalized later using the weight scale variable)
                                        VtoAverage(p,k) = Weight*(vGasData(j,i)-ParticleVelocityV)/abs(AverageGasPhaseU - ParticleVelocityU);
                                        Iterations(p,k) = Iterations(p,k)+1; %Checking how many Iterations was used for summing each individual grid point. Not really necessary since I am already assigning percentage weights but I just like to see it for my own sanity
                                        WeightScale(p,k) = WeightScale(p,k) + Weight; %Checking if the weights of the average add up to 1. If they don't, this will be used to renormalize the data at the end such that it does
                                    end
                                end

                            end
                            SumUInertial = SumUInertial + UtoAverage;
                            SumVInertial = SumVInertial + VtoAverage;
                        end


                end
            end

            UInertial{Run}{GasFrame,m} = SumUInertial./WeightScale; %Renormalizing the velocities this is now you average
%             UInertial{Run}{Frame,m}(isnan(UInertial{Run}{Frame,m})) = 0; %Center (where particle is) will be NaN since you are dividing by 0 in above line in this region so replace NaN with 0 values

            VInertial{Run}{GasFrame,m} = SumVInertial./WeightScale; %Renormalizing the velocities this is now you average
%             VInertial{Run}{Frame,m}(isnan(VInertial{Run}{Frame,m})) = 0; %Center (where particle is) will be NaN since you are dividing by 0 in above line in this region so replace NaN with 0 values

        end
    end
end
save([analyzeddirec '\VelocityAroundInertialParticles.mat'],'UInertial','VInertial',"IntWinSize","D_HL","D_VD","RightBound","LeftBound","UpperBound","LowerBound","Diameter",'GridType','DiameterBuffer')

function Diameter = GetParticleDiameter(ParticleDiameter)

if ParticleDiameter == 200e-6
    Diameter = 30;
elseif ParticleDiameter == 139e-6
    Diameter = 45;

end
end