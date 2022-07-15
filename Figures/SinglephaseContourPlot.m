%% Directories
Tnum = 7;
P0 = 25; %psi
Mach = 1;
datdirec = ['E:\PIV Data\Raw Data\2022_06_28\T' num2str(Tnum)];
processeddirec = ['E:\PIV Data\Processed Data\2022_06_28\T' num2str(Tnum)];
analyzeddirec = ['E:\PIV Data\Analyzed Results\2022_06_28\T' num2str(Tnum)];

load([analyzeddirec '\PIVData.mat'])



%% 
D = 2e-3;
sizeX = size(ucal{1}{1},1); sizeY = size(ucal{1}{1},2);
for i = 1: numel(ucal)
    ucalConcat = zeros(sizeX,sizeY,numel(ucal{1,i}));
    for j = 1:numel(ucal{1,i})
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
title(['$P_0$ = ' num2str(P0) ' psi; Mach = ' num2str(Mach)],'fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');
ylabel('$y/D$','fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');
xlabel('$x/D$','fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');


set(gcf,'Position',[100 100 1280 762])

saveas(gcf,[analyzeddirec '\Contour Plot'],'svg')



