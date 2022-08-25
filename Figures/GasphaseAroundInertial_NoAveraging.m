%% Directories
clear; close all
Tnum = 4;
datdirec = ['D:\PIV Data\Raw Data\2022_06_27\T' num2str(Tnum)];
processeddirec = ['D:\PIV Data\Processed Data\2022_06_27\T' num2str(Tnum)];
analyzeddirec = ['D:\PIV Data\Analyzed Results\2022_06_27\T' num2str(Tnum)];

% Plot settings
axiswidth = 2; linewidth = 2; fontsize = 18;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

% ParticleDiameter = 139e-6;
dperPix = 6.625277859765377e-06;
AverageFrames = 1; %Do you want to average over the frames at least
%%

load([analyzeddirec '\VelocityAroundInertialParticles.mat'])
load([analyzeddirec '\InertialParticalSelection.mat'],'ParticlesOfInterest','avgDiameter')
load([analyzeddirec '\LPTData.mat'],'vtracks','tracks')

ParticleOfInterest = ParticlesOfInterest;
Run = 1;
Frame = 4;
ParticleNum = 1;

if AverageFrames == 1

    UConcat = zeros(size(UInertial{Run}{Frame,ParticleNum},1),size(UInertial{Run}{Frame,ParticleNum},2),size(UInertial{Run},1));
    VConcat = zeros(size(UConcat));
    m = 0;
    for Frames = 1:size(UInertial{Run},1)
        if isempty(UInertial{Run}{Frames,ParticleNum})
            continue
        end
        m = m + 1;
        UConcat(:,:,m) = UInertial{Run}{Frames,ParticleNum};
        VConcat(:,:,m) = VInertial{Run}{Frames,ParticleNum};
    end
    avgUInertial = mean(UConcat,3,'omitnan');
    avgVInertial = mean(VConcat,3,'omitnan');
else
    avgUInertial = UInertial{Run}{Frame,ParticleNum};
    avgVInertial = VInertial{Run}{Frame,ParticleNum};
end

avgUInertial(avgUInertial<=0) = NaN;


%% Plot Image with particle position so we know which we are looking at
ParticleLocationRealX = vtracks{Run}(ParticlesOfInterest{Run}.ParticleNum(ParticleNum)).X;
ParticleLocationRealY = vtracks{Run}(ParticlesOfInterest{Run}.ParticleNum(ParticleNum)).Y;

img = imread([processeddirec '\Tracer Particles\R' num2str(Run) '\data_' sprintf('%03d',Frame) '.tiff']);
figure
imshow(img)
hold on
scatter(ParticleLocationRealX, ParticleLocationRealY, 30, 'blue','filled')
hold off


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
% Diameter = avgDiameter+DiameterBuffer; %pix
Diameter = avgDiameter;

switch GridType
    case 'Constant Diameter'
        ParticleLocationX = Diameter/2 + D_HL*IntWinSize;
        ParticleLocationY = Diameter/2+D_VD*IntWinSize;
    case 'Deformable Diameter'
        ParticleLocationX = D_HL*IntWinSize;
        ParticleLocationY = D_VD*IntWinSize;
end

[columnsInImage, rowsInImage] = meshgrid(1:FinalImageSizeX, 1:FinalImageSizeY);

circlePixels = (rowsInImage - ParticleLocationY).^2 + (columnsInImage - ParticleLocationX).^2 <= (Diameter/2).^2;
% circlePixels = flip(circlePixels,2);

[xgrid,ygrid] = meshgrid(0+IntWinSize/2:IntWinSize:FinalImageSizeX-IntWinSize/2, 0+IntWinSize/2:IntWinSize:FinalImageSizeY-IntWinSize/2);
% xgrid = -(xgrid-max(xgrid,[],2));

figure
imshow(circlePixels)
hold on
% avgVInertial = zeros(size(avgUInertial));
quiver(xgrid,ygrid,avgUInertial,avgVInertial);
set(gcf,'Position',[59,367.6666666666666,1280,800])
hold off