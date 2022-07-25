%% Directories
Tnum = 3;
datdirec = ['E:\PIV Data\Raw Data\2022_06_30\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_06_30\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_06_30\T' num2str(Tnum)];

% Plot settings
axiswidth = 2; linewidth = 2; fontsize = 18;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

% ParticleDiameter = 139e-6;
dperPix = 6.625277859765377e-06;

%%

load([analyzeddirec '\VelocityAroundInertialParticles.mat'])
load([analyzeddirec '\InertialParticalSelection.mat'],'ParticleOfInterest','avgDiameter')

Run = 1;
Frame = 2;
ParticleNum = 1;

avgUInertial = UInertial{Run}{Frame,ParticleNum};
avgVInertial = VInertial{Run}{Frame,ParticleNum};

%% Plotting final contour
Diameter = ParticleOfInterest{Run}.ParticleDiameter(ParticleNum);
FinalImageSizeX = RightBound-LeftBound; FinalImageSizeY = UpperBound-LowerBound;

ParticleLocationX = Diameter/2 + D_HL*IntWinSize;
ParticleLocationY = Diameter/2+D_VD*IntWinSize;

[columnsInImage, rowsInImage] = meshgrid(1:FinalImageSizeX, 1:FinalImageSizeY);

circlePixels = (rowsInImage - ParticleLocationY).^2 + (columnsInImage - ParticleLocationX).^2 <= (Diameter/2).^2;
% circlePixels = flip(circlePixels,2);

[xgrid,ygrid] = meshgrid(0+IntWinSize/2:IntWinSize:FinalImageSizeX-IntWinSize/2, 0+IntWinSize/2:IntWinSize:FinalImageSizeY-IntWinSize/2);
% xgrid = -(xgrid-max(xgrid,[],2));

figure
contourf(xgrid,ygrid,avgUInertial,10)
c = colorbar('eastoutside');
c.Label.String = '$u$ (m/s)';
c.Label.FontName  = 'Times New roman';
c.Label.FontSize = 30;
c.Label.FontAngle = 'italic';
c.Label.Interpreter = 'latex';
set(gca,'LineWidth',2.5);
set(gca,'fontsize',20);
% title(['$P_0$ = ' num2str(P0) ' psi; $D_p$ = ' num2str(ParticleSize) '$\mu m$'],'fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');
ylabel('$y/D$','fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');
xlabel('$x/D$','fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');


set(gcf,'Position',[100 100 1280 762])

saveas(gcf,[analyzeddirec '\Contour Plot'],'svg')
% hold on
% Irgb = cat(3,circlePixels,circlePixels,circlePixels);
% image(Irgb)
% 
% hold off
%%
FinalImageSizeX = RightBound-LeftBound; FinalImageSizeY = UpperBound-LowerBound;
Diameter = ParticleOfInterest{Run}.ParticleDiameter(ParticleNum);

ParticleLocationX = Diameter/2 + D_HL*IntWinSize;
ParticleLocationY = Diameter/2+D_VD*IntWinSize;

[columnsInImage, rowsInImage] = meshgrid(1:FinalImageSizeX, 1:FinalImageSizeY);

circlePixels = (rowsInImage - ParticleLocationY).^2 + (columnsInImage - ParticleLocationX).^2 <= (Diameter/2).^2;
% circlePixels = flip(circlePixels,2);

[xgrid,ygrid] = meshgrid(0+IntWinSize/2:IntWinSize:FinalImageSizeX-IntWinSize/2, 0+IntWinSize/2:IntWinSize:FinalImageSizeY-IntWinSize/2);
% xgrid = -(xgrid-max(xgrid,[],2));
figure
imshow(circlePixels)
hold on
% avgVInertial = zeros(size(avgUInertial));
quiver(xgrid,ygrid,avgUInertial,avgVInertial)

hold off