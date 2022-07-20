%% Directories
Tnum = 3;
datdirec = ['D:\PIV Data\Raw Data\2022_06_30\T' num2str(Tnum)];
processeddirec = ['D:\PIV Data\Processed Data\2022_06_30\T' num2str(Tnum)];
analyzeddirec = ['D:\PIV Data\Analyzed Results\2022_06_30\T' num2str(Tnum)];

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

IntWinSize = (x{1,1}{1,1}(1,2)-x{1,1}{1,1}(1,1)); %pixels %Getting the Interrogation window size of the PIV data
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
        ParticleVelocityU = mean(vtracks{Run}(ParticleNum).U)*dperPix*FPS; %m/s
        ParticleVelocityV = mean(vtracks{Run}(ParticleNum).V)*dperPix*FPS; %m/s

        % Setting up bounds for this particle
        LeftBound = ceil(ParticleLocationX - Diameter/2 - D_HL*IntWinSize);
        RightBound = ceil(ParticleLocationX + Diameter/2+D_HR*IntWinSize);
        UpperBound = ceil(ParticleLocationY + Diameter/2+D_VUP*IntWinSize);
        LowerBound = ceil(ParticleLocationY - Diameter/2 - D_VD*IntWinSize);

        for Frame = 1:numel(ParticleLocationX)

            circlePixels = (rowsInImage - ParticleLocationY(Frame)).^2 + (columnsInImage - ParticleLocationX(Frame)).^2 <= (Diameter/2).^2; %Creating logical array size of final image with 1's where the particle is and 0's everywhere else

            [xgrid,ygrid] = meshgrid(LeftBound(Frame)+IntWinSize/2:IntWinSize:RightBound(Frame)-IntWinSize/2 ...
                , LowerBound(Frame)+IntWinSize/2:IntWinSize:UpperBound(Frame)-IntWinSize/2);
            SumUInertial = zeros(size(xgrid,1),size(xgrid,2));
            SumVInertial = zeros(size(xgrid,1),size(xgrid,2));
            Iterations = zeros(size(xgrid,1),size(xgrid,2));
            WeightScale = zeros(size(xgrid,1),size(xgrid,2));

            for i = 1:size(x{Run}{Frame},2) %loop through all x values of the data grid
               
                xdata = x{Run}{Frame}(1,i); %determine x values from data grid

                for j = 1:size(x{Run}{Frame},1) %Loop through all y values of the data grid
                    ydata = y{Run}{Frame}(j,1); %determine y values from data grid

                    if xdata<max(xgrid(1,:))+IntWinSize/2 && xdata>min(xgrid(1,:))-IntWinSize/2 && ydata<max(ygrid(:,1))+IntWinSize/2 && ydata > min(ygrid(:,1))-IntWinSize/2 %Check to see if the value from data grid is within the region of interest for that inertial particle

                        if ~circlePixels(ydata,xdata) %Ensures that we don't account for data that is within the particle radius of the final grid.
                            UtoAverage = zeros(size(xgrid,1),size(xgrid,2));
                            VtoAverage = zeros(size(xgrid,1),size(xgrid,2));
                            for k = 1:size(xgrid,2) %Loop through the new made up grid x values
                                D_H = abs(xdata-xgrid(1,k)); %Obtain the horizontal distance between the data x value and the made up grid x value

                                for p = 1:size(xgrid,1) %Loop through the new made up grid y values
                                    D_V = abs(ydata - ygrid(p,1)); %Obtain the vertical distance between the data y value and the made up grid y value
                                    %                         if xgrid(1,k) > 0 && xgrid(1,k) < 400 && ygrid(p,1) > 0 && ygrid(p,1)<250
                                    if D_H < IntWinSize && D_V < IntWinSize &&  ~circlePixels(ygrid(p,1),xgrid(1,k)) && ucal{Run}{Frame}(j,i) > 50%Check to see if the data grid box is overlapping with the made up grid box
                                        Xoverlap = IntWinSize - D_H; %obtain the amount of overlap in x distance
                                        Yoverlap = IntWinSize - D_V; %obtain the amount of overlap of in y distance

                                        AreaOverlap = Xoverlap*Yoverlap; %Calculate the area of the shaded region
                                        Weight = AreaOverlap/(IntWinSize^2); %Obtain the percentage of the overlap region that makes up the total area of the interogation window this will be our averaging weight

                                        UtoAverage(p,k) = Weight*ucal{Run}{Frame}(j,i)/(ucal{Run}{Frame}(j,i)-ParticleVelocityU); %Applying the weight to the averaging (will be renormalized later using the weight scale variable)
                                        VtoAverage(p,k) = Weight*vcal{Run}{Frame}(j,i)/(vcal{Run}{Frame}(j,i)-ParticleVelocityV);
                                        Iterations(p,k) = Iterations(p,k)+1; %Checking how many Iterations was used for summing each individual grid point. Not really necessary since I am already assigning percentage weights but I just like to see it for my own sanity
                                        WeightScale(p,k) = WeightScale(p,k) + Weight; %Checking if the weights of the average add up to 1. If they don't, this will be used to renormalize the data at the end such that it does
                                    end
                                    %                         end

                                end

                            end
                            SumUInertial = SumUInertial + UtoAverage;
                            SumVInertial = SumVInertial + VtoAverage;
                        end
                    end

                end
            end

            UInertial{Run}{Frame,m} = SumUInertial./WeightScale; %Renormalizing the velocities this is now you average
            UInertial{Run}{Frame,m}(isnan(UInertial{Run}{Frame,m})) = 0; %Center (where particle is) will be NaN since you are dividing by 0 in above line in this region so replace NaN with 0 values

            VInertial{Run}{Frame,m} = SumVInertial./WeightScale; %Renormalizing the velocities this is now you average
            VInertial{Run}{Frame,m}(isnan(VInertial{Run}{Frame,m})) = 0; %Center (where particle is) will be NaN since you are dividing by 0 in above line in this region so replace NaN with 0 values

        end
    end
end
save([analyzeddirec '\VelocityAroundInertialParticles.mat'], 'xgrid','ygrid','UInertial','VInertial',"IntWinSize","D_HL","D_VD","RightBound","LeftBound","UpperBound","LowerBound","Diameter")