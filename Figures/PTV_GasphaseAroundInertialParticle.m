%% Directories
Tnum = 3;
datdirec = ['E:\PIV Data\Raw Data\2022_07_01\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_07_01\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_07_01\T' num2str(Tnum)];

% Plot settings
axiswidth = 2; linewidth = 2; fontsize = 18;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';


dperPix = 6.625277859765377e-06;

%%

load([analyzeddirec '\PTV_VelocityAroundInertialParticles.mat'])
UInertial = UInertial(~cellfun('isempty',UInertial));


sizeX = size(UInertial{1}{1,1},1); sizeY = size(UInertial{1}{1,1},2);
UInertialConcat = zeros(sizeX,sizeY,numel(UInertial));
m = 0;
for i = 1: numel(UInertial)
    UInertial{i} = UInertial{i}(~cellfun('isempty',UInertial{i}));
    for j = 1:size(UInertial{i},1)
        for k = 1:size(UInertial{i},2)
            m = m+1;
            UInertial{i}{j,k}(UInertial{i}{j,k}<=0 | UInertial{i}{j,k}>=1.6) = NaN;
%             UInertial{i}{j,k}(UInertial{i}{j,k}<=0) = NaN;

            UInertialConcat(:,:,m) = UInertial{i}{j,k};
        end
    end
end

avgUInertial = mean(UInertialConcat,3,'omitnan');

%% Plotting final contour

FinalImageSizeX = RightBound(1)-LeftBound(1); FinalImageSizeY = UpperBound(1)-LowerBound(1);


[xgrid,ygrid] = meshgrid(0+IntWinSize/2:IntWinSize:FinalImageSizeX-IntWinSize/2, 0+IntWinSize/2:IntWinSize:FinalImageSizeY-IntWinSize/2);

if ygrid(end,1) ~= FinalImageSizeY-IntWinSize/2
    ygrid(end+1,:) = repmat(FinalImageSizeY-IntWinSize/2,size(ygrid,2),1);
    ygrid(:,end+1) = ygrid(:,1);
end
if xgrid(1,end) ~= FinalImageSizeX-IntWinSize/2
    xgrid(:,end+1) = repmat(FinalImageSizeX-IntWinSize/2,size(xgrid,1),1);
    xgrid(end+1,:) = xgrid(1,:);
end

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

% saveas(gcf,[analyzeddirec '\Contour Plot'],'svg')
