%% Directories
Tnum = 4;
datdirec = ['D:\PIV Data\Raw Data\2022_07_01\T' num2str(Tnum)];
processeddirec = ['D:\PIV Data\Processed Data\2022_07_01\T' num2str(Tnum)];
analyzeddirec = ['D:\PIV Data\Analyzed Results\2022_07_01\T' num2str(Tnum)];


% Plot settings
axiswidth = 2; linewidth = 2; 
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';


HorizontalVelocityCutOff = 50; %m/s
P0 = 95; 
ParticleSize = 137.5; %micron



load([analyzeddirec '\PIVData.mat'])


%% 

D = 2e-3;
sizeX = size(ucal{1}{1},1); sizeY = size(ucal{1}{1},2);
for i = 1: numel(ucal)
    ucalConcat = zeros(sizeX,sizeY,numel(ucal{1,i}));
    for j = 1:numel(ucal{1,i})
        ucal{1,i}{j,1}(ucal{1,i}{j,1}<HorizontalVelocityCutOff) = NaN;
        ucalConcat(:,:,j) = ucal{1,i}{j,1};
    end
    avgURuns(:,:,i) = mean(ucalConcat,3,'omitnan');
end


% Averaging all runs to each other
avgUFinal = mean(avgURuns,3,'omitnan');


contourf(xcal{1}{1}/D,ycal{1}{1}/D,avgUFinal)
c = colorbar('eastoutside');
c.Label.String = '$u$ (m/s)';
c.Label.FontName  = 'Times New roman';
c.Label.FontSize = 30;
c.Label.FontAngle = 'italic';
c.Label.Interpreter = 'latex';
set(gca,'LineWidth',2.5);
set(gca,'fontsize',20);
title(['$P_0$ = ' num2str(P0) ' psi; $D_p$ = ' num2str(ParticleSize) '$\mu m$'],'fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');
ylabel('$y/D$','fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');
xlabel('$x/D$','fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');


set(gcf,'Position',[100 100 1280 762])

saveas(gcf,[analyzeddirec '\Contour Plot'],'svg')



