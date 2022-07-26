%% Directories
Tnum = 3;
datdirec = ['E:\PIV Data\Raw Data\2022_06_30\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_06_30\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_06_30\T' num2str(Tnum)];

% Plot settings
axiswidth = 2; linewidth = 2; fontsize = 18;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';


dperPix = 6.625277859765377e-06;

%%

load([analyzeddirec '\VelocityAroundInertialParticles.mat'])
load([analyzeddirec '\InertialParticalSelection.mat'], 'avgDiameter')

UInertial = UInertial(~cellfun('isempty',UInertial));
VInertial = VInertial(~cellfun('isempty',VInertial));


sizeX = size(UInertial{1}{2,1},1); sizeY = size(UInertial{1}{2,1},2);
UInertialConcat = zeros(sizeX,sizeY,numel(UInertial));
m = 0;
for i = 1: numel(UInertial)
    UInertial{i} = UInertial{i}(~cellfun('isempty',UInertial{i}));
    VInertial{i} = VInertial{i}(~cellfun('isempty',VInertial{i}));
    for j = 1:size(UInertial{i},1)
        for k = 1:size(UInertial{i},2)
            m = m+1;
% %             UInertial{i}{j,k}(UInertial{i}{j,k}<=0 | UInertial{i}{j,k}>=10) = NaN;
            UInertial{i}{j,k}(UInertial{i}{j,k}<=0| UInertial{i}{j,k}>=10) = NaN;
            VInertial{i}{j,k}(VInertial{i}{j,k}<=0 | abs(VInertial{i}{j,k})>=10) = NaN;

            UInertialConcat(:,:,m) = UInertial{i}{j,k};
            VInertialConcat(:,:,m) = VInertial{i}{j,k};
        end
    end
end

avgUInertial = mean(UInertialConcat,3,'omitnan');
avgVInertial = mean(VInertialConcat,3,'omitnan');

%% Plotting final contour
Diameter = avgDiameter;
FinalImageSizeX = RightBound-LeftBound; FinalImageSizeY = UpperBound-LowerBound;


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
Diameter = avgDiameter+DiameterBuffer; %pix

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
quiver(xgrid,ygrid,avgUInertial,avgVInertial)

hold off