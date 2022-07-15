
P0 = 50; 
ParticleSize = 100;

if P0 == 50 %psi
    analyzeddirec{1,1} = ['D:\PIV Data\Analyzed Results\2022_06_27\T3'];
    analyzeddirec{2,1} = ['D:\PIV Data\Analyzed Results\2022_07_01\T6'];
elseif P0 == 95 %psi
    analyzeddirec{1,1} = ['D:\PIV Data\Analyzed Results\2022_06_27\T4'];
    analyzeddirec{2,1} = ['D:\PIV Data\Analyzed Results\2022_07_01\T5'];
end

b = 0;
D = 2e-3;

for k = 1:numel(analyzeddirec)
    load([analyzeddirec{k} '\PIVData.mat'])
    sizeX = size(ucal{1}{1},1); sizeY = size(ucal{1}{1},2);
    for i = 1: numel(ucal)
        ucalConcat = zeros(sizeX,sizeY,numel(ucal{1,i}));
        for j = 1:numel(ucal{1,i})
            ucal{1,i}{j,1}(ucal{1,i}{j,1}<50) = NaN;
            ucalConcat(:,:,j) = ucal{1,i}{j,1};   
        end
        b = b+1; 
        avgURuns(:,:,b) = mean(ucalConcat,3,'omitnan');
    end
end


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






