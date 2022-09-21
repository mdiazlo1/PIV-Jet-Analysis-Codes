%% Directories
Tnum = 4; Run = 1;
direc = DirectoryAssignment('E:\PIV Data','2022_06_27',Tnum,Run,0);
[~,~,analyzeddirec] = direc.GeneratePaths();

% Plot settings
axiswidth = 2; linewidth = 2; fontsize = 18;
red_color = '#de2d26'; blue_color = '#756bb1';
green_color = '#31a354'; black_color = '#000000';

% ConvolutionFilter = 8; %Probably best to just utilize maximum amount of
% frames available for convolution unless I have to make them all the same
% (don't think I do if I am averaging over everything anyway)
Gamma = 1.4; %Specific heat ratio of air
P_t = 50; %psi %Throat pressure for isentropic calculations (plenum pressure)
T_t = 298.15; %K %Throat temperauture for isentropic calculations (Assume ambient condition)
[rhof, mu,~,~,~] = FluidProperties(P_t,T_t);
rhof = 1000*real(rhof); %kg/m^3
mu = real(mu)/10; %Pa*s

dperPix = 6.625277859765377e-06;

%%

load([analyzeddirec '\VelocityAroundInertialParticles.mat'])
load([analyzeddirec '\InertialParticalSelection.mat'], 'avgDiameter')
load([analyzeddirec '\LPTData.mat'])

UInertial = UInertial(~cellfun('isempty',UInertial));
VInertial = VInertial(~cellfun('isempty',VInertial));


sizeX = size(UInertial{1}{2,1},1); sizeY = size(UInertial{1}{2,1},2);
UInertialConcat = zeros(sizeX,sizeY,numel(UInertial));
VInertialConcat = zeros(sizeX,sizeY,numel(VInertial));
m = 0;
for i = 1: numel(UInertial)
%     UInertial{i} = UInertial{i}(~cellfun('isempty',UInertial{i}));
%     VInertial{i} = VInertial{i}(~cellfun('isempty',VInertial{i}));
    
    for j = 1:size(UInertial{i},1)
        for k = 1:size(UInertial{i},2)
            if isempty(UInertial{i}{j,k})
                continue
            end
            m = m+1;
            UInertial{i}{j,k}(UInertial{i}{j,k}<=0 | UInertial{i}{j,k}>=10) = NaN;
%             UInertial{i}{j,k}(UInertial{i}{j,k}<=0| UInertial{i}{j,k}>=10) = NaN;
%             VInertial{i}{j,k}(abs(VInertial{i}{j,k})>=10) = NaN;

            UInertialConcat(:,:,m) = UInertial{i}{j,k};
            VInertialConcat(:,:,m) = VInertial{i}{j,k};
        end
    end
end

avgUInertial = mean(UInertialConcat,3,'omitnan');
avgVInertial = mean(VInertialConcat,3,'omitnan');

%% Plot Contour for visualization
Diameter = avgDiameter;
FinalImageSizeX = RightBound-LeftBound; FinalImageSizeY = UpperBound-LowerBound;


% circlePixels = flip(circlePixels,2);

[xgrid,ygrid] = meshgrid(0+IntWinSize/2:IntWinSize:FinalImageSizeX-IntWinSize/2, 0+IntWinSize/2:IntWinSize:FinalImageSizeY-IntWinSize/2);
% xgrid = -(xgrid-max(xgrid,[],2));

figure

contourf(xgrid,ygrid,avgUInertial,10)
c = colorbar('eastoutside');
c.Label.String = '$\Delta u / \Delta u_{avg}$ ';
c.Label.FontName  = 'Times New roman';
c.Label.FontSize = 30;
c.Label.FontAngle = 'italic';
c.Label.Interpreter = 'latex';
set(gca,'LineWidth',2.5);
set(gca,'fontsize',20);
% title(['$P_0$ = ' num2str(P0) ' psi; $D_p$ = ' num2str(ParticleSize) '$\mu m$'],'fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');
ylabel('$y/D$','fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');
xlabel('$x/D$','fontsize',30,'fontname','Times New Roman','fontangle','italic','interpreter','latex');


set(gcf,'Position',[59,367.6666666666666,1280,800])
%% Isentropic flow conditions
%Use the average gas phase velocity of the window to calculate properties
%using isentropic conditions (but data is already normalized by slip
%velocity you will need to see how you would un normalize it or else you'll
%have to redo analysis and save the average gas phase velocities which is
%probably easiest)

%Yeah just resave, because you also need unnormalized data for the entire
%window for each case so that you can use it to calculate coefficient of
%drag
c = 340; %Speed of sound
M = AverageU/C;
P = P_t*(1+(gamma-1)/2*M^2)^(-gamma/(gamma-1));
rho = rho_t*(P/P_t)^(1/gamma);


%% Coefficient of drag with Reynolds Number

