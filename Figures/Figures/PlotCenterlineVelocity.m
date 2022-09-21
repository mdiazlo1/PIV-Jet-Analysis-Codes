%% Set up directories
axiswidth = 2; linewidth = 2; fontsize = 24;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';
orange_color = '#fdae6b';

Dates = ['2022_06_28';'2022_06_30';'2022_07_01';'100 micron';'2022_06_28'];
% Dates = '2022_06_28';
T = [5 3 3 3 3];
% T = 4;
title1 = '$P_0 = 50 psi$';
Run = 1;
direc = DirectoryAssignment('E:\PIV Data',0,0,Run,0);
figure
hold on
Color = [black_color;red_color;green_color;blue_color;orange_color];
BufferRegion = 0; %How many rows on top and bottom of centerline you want to include in the averaging

for L = 1:numel(T)
    if numel(Dates)>1
        direc.Date = Dates(L,:);
    else
        direc.Date = Dates;
    end

direc.Tnum = T(L); 

[~,~,analyzeddirec] = direc.GeneratePaths();


HorizontalVelocityCutOff = 25; %m/s


if direc.Date ~= "100 micron"
    load([analyzeddirec,'\PIVData.mat'])
end


%%
if direc.Date == "100 micron"
    clearvars analyzeddirec
    P0 = 50;
    ParticleSize = 100;

    if P0 == 50 %psi
        analyzeddirec{1,1} = 'E:\PIV Data\Analyzed Results\2022_06_27\T3';
        analyzeddirec{2,1} = 'E:\PIV Data\Analyzed Results\2022_07_01\T6';
    elseif P0 == 95 %psi
        analyzeddirec{1,1} = 'E:\PIV Data\Analyzed Results\2022_06_27\T4';
        analyzeddirec{2,1} = 'E:\PIV Data\Analyzed Results\2022_07_01\T5';
    end

    b = 0;
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
else
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
end
D = 2e-3;

centerline = round(size(ycal{1}{1},1)/2);

avgUCenterline = mean(avgUFinal(centerline-BufferRegion:centerline+BufferRegion,:),1);

plot(xcal{1}{1}(centerline,:)/D,avgUCenterline,'color',Color(L,:))
if strcmp(Dates(L,:),'2022_06_28')
    [PeakVelUnladen, idx] = max(avgUCenterline);
    ShockLocationUnladen = xcal{1}{1}(centerline,idx)/D;
end

end
hold off


set(gcf,'Position',[61.800000000000004,68.2,930.4000000000001,789.6])
xlabel('$x$/$D$','interpreter','latex','fontName','TimesNewRoman','FontSize',fontsize+6)
ylabel('$u_{c}$','interpreter','latex','fontName','TimesNewRoman','FontSize',fontsize+6)
xline(ShockLocationUnladen,'k--','linewidth',2)
xline(ShockLocationUnladen-ShockLocationUnladen*0.1,'linestyle','--','Color',[0.3 0.3 0.3],'linewidth',2)
xline(ShockLocationUnladen-ShockLocationUnladen*0.15,'linestyle','--','Color',[0.6 0.6 0.6],'linewidth',2)

legend('Unladen','200 $\mathrm{\mu m}$; Low Concentration'...
    ,'137.5 $\mathrm{\mu m}$; High Concentration','100 $\mathrm{\mu m}$; Higher Concentration'...
   ,'29 $\mathrm{\mu m}$; Low concentration','Shock Location Unladen',...
   '$10\%$ Shock','$15\%$ Shock','location','eastoutside','interpreter','latex')


% legend('Unladen','200 $\mathrm{\mu m}; Low Concentration'...
%     ,'125 $\mathrm{\mu m}; High Concentration','100 $\mathrm{\mu m}; Higher Concentration'...
%    ,'location','southeast')

title(title1,'interpreter','latex')
PrettyFigures(linewidth,fontsize,axiswidth)

