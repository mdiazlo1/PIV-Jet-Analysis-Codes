%% Set up directories
axiswidth = 2; linewidth = 2; fontsize = 24;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';
orange_color = '#fdae6b';

Dates = ['2022_06_28'];
% Dates = '2022_06_28';

Run = [1];
T = 5;
title1 = '$P_0 = 50 \mathrm{psi}; d_p = 200 \mathrm{\mu m}$';
direc = DirectoryAssignment('D:\PIV Data',0,0,0,0);
figure
hold on
Color = [black_color;red_color;green_color;blue_color;orange_color];
BufferRegion = 0; %How many rows on top and bottom of centerline you want to include in the averaging

for L = 1:numel(Run)
  

    direc.Date = Dates;

direc.Tnum = T; direc.Run = Run(L); 

[~,~,analyzeddirec] = direc.GeneratePaths();


HorizontalVelocityCutOff = 25; %m/s

%%
if direc.Date == "100 micron"
    clearvars analyzeddirec
    P0 = 95;
    ParticleSize = 100;

    if P0 == 50 %psi
        analyzeddirec{1,1} = 'D:\PIV Data\Analyzed Results\2022_06_27\T3';
        analyzeddirec{2,1} = 'D:\PIV Data\Analyzed Results\2022_07_01\T6';
    elseif P0 == 95 %psi
        analyzeddirec{1,1} = 'D:\PIV Data\Analyzed Results\2022_06_27\T4';
        analyzeddirec{2,1} = 'D:\PIV Data\Analyzed Results\2022_07_01\T5';
    end

else
    load([analyzeddirec,'\PIVData.mat'])
end
D = 2e-3;

centerline = round(size(ycal{1}{1},1)/2);

avgU = mean(cat(3,ucal{Run(L)}{:}),3);
avgUCenterline = mean(avgU(centerline-BufferRegion:centerline+BufferRegion,:),1);

plot(xcal{1}{1}(centerline,:)/D,avgUCenterline,'color',[0.5 0.5 0.5]+(L-1)/(numel(Run)*2),...
    'DisplayName',['R = ' num2str(Run(L))])


end
hold off

PrettyFigures(linewidth,fontsize,axiswidth)

set(gcf,'Position',[61.800000000000004,68.2,930.4000000000001,789.6])
xlabel('$x$/$D$','interpreter','latex','fontName','TimesNewRoman','FontSize',fontsize+6)
ylabel('$u_{c}$','interpreter','latex','fontName','TimesNewRoman','FontSize',fontsize+6)
legend

title(title1,'interpreter','latex')
