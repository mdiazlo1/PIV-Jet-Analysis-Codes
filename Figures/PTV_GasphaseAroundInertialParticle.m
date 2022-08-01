%% Directories
Dates = ['2022_06_22';'2022_06_23';'2022_06_30']; Tnum = [3 3 3]; Run = 0;
for p = 1:size(Dates,1)

    direc = DirectoryAssignment('E:\PIV Data',Dates(p,:),Tnum(p),Run,0);
    [~,~,analyzeddirec] = direc.GeneratePaths();

    % Plot settings
    axiswidth = 2; linewidth = 2; fontsize = 18;
    red_color = '#de2d26'; blue_color = '#756bb1';
    green_color = '#31a354'; black_color = '#000000';

    dperPix = 6.625277859765377e-06;

    %%

    load([analyzeddirec '\PTV_VelocityAroundInertialParticles.mat'])
    UInertial = UInertial(~cellfun('isempty',UInertial));


    UInertial = UInertial(~cellfun('isempty',UInertial));
    VInertial = VInertial(~cellfun('isempty',VInertial));


    sizeX = size(UInertial{1}{2,1},1); sizeY = size(UInertial{1}{2,1},2);
    UInertialConcat = zeros(sizeX,sizeY,numel(UInertial)); VInertialConcat = zeros(sizeX,sizeY,numel(VInertial));
    
    m = 0;
    for i = 1: numel(UInertial)
        UInertial{i} = UInertial{i}(~cellfun('isempty',UInertial{i}));
        VInertial{i} = VInertial{i}(~cellfun('isempty',VInertial{i}));
        for j = 1:size(UInertial{i},1)
            for k = 1:size(UInertial{i},2)
                m = m+1;
                % %             UInertial{i}{j,k}(UInertial{i}{j,k}<=0 | UInertial{i}{j,k}>=10) = NaN;
                UInertial{i}{j,k}(UInertial{i}{j,k}<=0| UInertial{i}{j,k}>=1.5) = NaN;
%                 VInertial{i}{j,k}(VInertial{i}{j,k}<=0 | abs(VInertial{i}{j,k})>=10) = NaN;

                UInertialConcat(:,:,m) = UInertial{i}{j,k};
                VInertialConcat(:,:,m) = VInertial{i}{j,k};
            end
        end
    end
%     if p ~=1 && size(UInertialConcat,[1 2]) ~= size(avgUInertialDates,[1 2])
%         if size(UInertialConcat,[1 2]) < size(avgUInertialDates,[1 2])
%             
%         end


    avgUInertialDates(:,:,p) = mean(UInertialConcat,3,'omitnan');
    avgVInertialDates(:,:,p) = mean(VInertialConcat,3,'omitnan');
end

avgUInertial = mean(avgUInertialDates,3,'omitnan');
avgVInertial = mean(avgVInertialDates,3,'omitnan');
%% Plotting final contour

FinalImageSizeX = RightBound(1)-LeftBound(1); FinalImageSizeY = UpperBound(1)-LowerBound(1);

switch GridType
    case 'Constant Diameter'
        ParticleLocationX = Diameter/2 + D_HL*IntWinSize;
        ParticleLocationY = Diameter/2+D_VD*IntWinSize;
    case 'Deformable Diameter'
        ParticleLocationX = D_HL*IntWinSize;
        ParticleLocationY = D_VD*IntWinSize;
end
xgriddata = xgrid-min(xgrid,[],2);
ygriddata = ygrid-min(ygrid,[],1);
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
% contourf(xgrid,ygrid,avgUInertialDates(:,:,1),10)
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

%% Now create quiver plot with particle in the center
FinalImageSizeX = RightBound(1)-LeftBound(1); FinalImageSizeY = UpperBound(1)-LowerBound(1);

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


% [xgrid,ygrid] = meshgrid(0+IntWinSize/2:IntWinSize:FinalImageSizeX, 0+IntWinSize/2:IntWinSize:FinalImageSizeY);

figure
imshow(circlePixels)
hold on
% avgVInertial = zeros(size(avgUInertial));
% quiver(xgrid,ygrid,avgUInertialDates(:,:,1),avgVInertialDates(:,:,1))
quiver(xgrid,ygrid,avgUInertial,avgVInertial)

hold off

