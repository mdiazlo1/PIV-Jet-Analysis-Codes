figure
imshow(circlePixels)
hold on
L(1) = scatter(GasTrackX,GasTrackY,30,'blue','filled');
PlotRectangle(LeftBound(ParticleFrameIdx),RightBound(ParticleFrameIdx),UpperBound(ParticleFrameIdx),LowerBound(ParticleFrameIdx),xgrid(1,minXIdx),ygrid(minYIdx,1),IntWinSize)
L(2) = scatter(xgrid(1,minXIdx),ygrid(minYIdx,1),30,'red','filled');

legend(L,'LPT Data','New Grid')

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
