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

load([analyzeddirec '\PIVData.mat'])


Run = 1;
Frame = 2;

xPlot = x{Run}{Frame}; yPlot = y{Run}{Frame};
uPlot = ucal{Run}{Frame}; vPlot = vcal{Run}{Frame};
figure
quiver(xPlot,yPlot,uPlot,vPlot)
hold on
L(1) = scatter(xdata,ydata,30,'blue','filled');
PlotRectangle(LeftBound(FrameIdx),RightBound(FrameIdx),UpperBound(FrameIdx),LowerBound(FrameIdx),xgrid(1,k),ygrid(p,1),IntWinSize)
L(2) = scatter(xgrid(1,k),ygrid(p,1),30,'red','filled');
if Iterations(p,k) ~= 0
    quiver(xgrid(1,k),ygrid(p,1),UtoAverage(p,k),VtoAverage(p,k))
end
legend(L,'PIV Data','New Grid')
hold off
%% Only run this if you have a particle location

% scatter(ParticleLocationX,ParticleLocationY,30,'red','filled')

%% Debugger
figure
imshow(circlePixels)
hold on
L(1) = scatter(xdata,ydata,30,'blue','filled');
PlotRectangle(LeftBound(FrameIdx),RightBound(FrameIdx),UpperBound(FrameIdx),LowerBound(FrameIdx),xgrid(1,k),ygrid(p,1),IntWinSize)
L(2) = scatter(xgrid(1,k),ygrid(p,1),30,'red','filled');
if Iterations(p,k) ~= 0
    quiver(xgrid(1,k),ygrid(p,1),UtoAverage(p,k),VtoAverage(p,k))
end
legend(L,'PIV Data','New Grid')

hold off

%%

function PlotRectangle(LeftBound,RightBound,UpperBound,LowerBound,xdata,ydata,IntWinSize)


xmin = LeftBound;
xmax = RightBound;

ymin = LowerBound;
ymax = UpperBound;
plot([xmin, xmin],[ymin,ymax],'r');
plot([xmax, xmax],[ymin,ymax],'r')
plot([xmin, xmax],[ymin,ymin],'r')
plot([xmin, xmax],[ymax,ymax],'r')

xmin = xdata-IntWinSize/2;
xmax = xdata+IntWinSize/2;

ymin = ydata-IntWinSize/2;
ymax = ydata+IntWinSize/2;
plot([xmin, xmin],[ymin,ymax],'r');
plot([xmax, xmax],[ymin,ymax],'r')
plot([xmin, xmax],[ymin,ymin],'r')
plot([xmin, xmax],[ymax,ymax],'r')

end
