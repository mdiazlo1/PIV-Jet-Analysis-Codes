%% Set up directories
axiswidth = 2; linewidth = 2; fontsize = 24;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';
orange_color = '#fdae6b';


Tnum = 5;
Run = 1;
direc = DirectoryAssignment('D:\PIV Data','2022_06_30',0,Run,0);
figure
hold on
Color = [black_color;red_color;green_color;blue_color;orange_color];
BufferRegion = 1; %How many rows on top and bottom of centerline you want to include in the averaging



[~,~,analyzeddirec] = direc.GeneratePaths();


HorizontalVelocityCutOff = 25; %m/s


if direc.Date ~= "100 micron"
    load([analyzeddirec,'\PIVData.mat'])
end


%%
if direc.Date == "100 micron"
    clearvars analyzeddirec
    P0 = 95;
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





PrettyFigures(linewidth,fontsize,axiswidth)

set(gcf,'Position',[341,105.6666666666667,1374,1172.666666666667])



