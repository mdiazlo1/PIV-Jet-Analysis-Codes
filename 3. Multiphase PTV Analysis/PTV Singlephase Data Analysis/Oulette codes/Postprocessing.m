load('ResultData.mat')


%% change the data structure, this is needed because my codes are written for cell data
celldata = struct2cell(vtracks);
Xcell = celldata(2,:);
Ycell = celldata(3,:);

%% this creates figure 7b in Nemes JFM 2017. It indicates what filter size to use
for l = 1:40
    [ ~, ~,ddxdtt] = cellfun(@gausdif012_Oulette_func,Xcell,repmat({l},size(Xcell)),'UniformOutput',0);
    % [ y, dydt,ddydtt] = cellfun(@gausdif012_Oulette_func,Ycell,repmat({l},size(Ycell)),'UniformOutput',0);
    var_a(l) = mean((cell2mat(ddxdtt)-mean(cell2mat(ddxdtt),'omitnan')).^2,'omitnan');
end
figure
plot(var_a,'.')
set(gca,'yscale','log')
xlabel('filter width')
ylabel('acceleration variance (pix/dt^2)')
drawnow

%% convolution of the data with a Gaussian (smoothing/filtering)
% Convolution with the derivative of a Gaussian gives smoothed velocity
% tracks. Convolution with the second derivative of a Guassian gives
% smoothed acceleration tracks

l_filt = 15;
[ x, dxdt,ddxdtt] = cellfun(@gausdif012_Oulette_func,Xcell,repmat({l_filt},size(Xcell)),'UniformOutput',0);
[ y, dydt,ddydtt] = cellfun(@gausdif012_Oulette_func,Ycell,repmat({l_filt},size(Ycell)),'UniformOutput',0);
ax = cell2mat(ddxdtt);
ay = cell2mat(ddydtt);
a = sqrt(ax.^2+ay.^2);
a_var = var(a,0);

%% normalized tracks (subtract mean)
mean_dxdt = mean(cell2mat(dxdt));
mean_dydt = mean(cell2mat(dydt));

[ norm_x ] = cellfun(@norm_traject_func,x,repmat({mean_dxdt},size(x)),'UniformOutput',0);
[ norm_y ] = cellfun(@norm_traject_func,y,repmat({mean_dydt},size(y)),'UniformOutput',0);

%% track lengths
L_tracks = cell2mat(celldata(1,:)); % length of the tracks
[L_sort,iL_sort] = sort(L_tracks,'descend'); % sorted lengths

%% plot tracks colored by horizontal velocity, Nemes figure 8b
% limits on the colorbar:
clim = [0 2]; % coloring with velocity
% clim = [0 1]*3; % coloring with acceleration magnitude

figure
caxis([clim])
colormap(jet(64))
cb=colorbar('eastoutside','ticklabelinterpreter','latex');
xlabel('horizontal (px)','interpreter','latex','fontsize',12)
ylabel('vertical (px)','interpreter','latex','fontsize',12)
set(gca,'ticklabelinterpreter','latex')
axis equal tight
% label for colorbar:
ylabel(cb,'$u (px/dt)$','interpreter','latex','fontsize',12) % velocity
% ylabel(cb,'$|a| (px/dt^2)$','interpreter','latex','fontsize',12) % acceleration

box on
hold on

for j = 1:1000
    ax_j = cell2mat(ddxdtt(iL_sort(j)));
    ay_j = cell2mat(ddydtt(iL_sort(j)));
    a_j = sqrt(ax_j.^2 + ay_j.^2);
    u_j = cell2mat(dxdt(iL_sort(j)));
    v_j = cell2mat(dydt(iL_sort(j)));
    V_j = sqrt(v_j.^2 + u_j.^2);
    xy = [x{iL_sort(j)}' y{iL_sort(j)}'];
    
    % color data:
    colo = [u_j;u_j]; % velocity
    %     colo = [a_j;a_j]/(sqrt(a_var)); % (normalized) acceleration magnitude
    
    surface([xy(:,1)';xy(:,1)'],[xy(:,2)';xy(:,2)'],colo,...
        'facecol','no',...
        'edgecol','interp',...
        'linew',2);
end
drawnow

%% plot normalized tracks, Nemes figure 8c
% limits on the colorbar:
% clim = [0 2]; % coloring with velocity
clim = [0 1]*3; % coloring with acceleration magnitude

figure
caxis([clim])
colormap(jet(64))
cb=colorbar('eastoutside','ticklabelinterpreter','latex');
xlabel('horizontal (px)','interpreter','latex','fontsize',12)
ylabel('vertical (px)','interpreter','latex','fontsize',12)
set(gca,'ticklabelinterpreter','latex')
axis equal tight
% label for colorbar:
% ylabel(cb,'$u (px/dt)$','interpreter','latex','fontsize',12) % velocity
ylabel(cb,'$|a| (px/dt^2)$','interpreter','latex','fontsize',12) % acceleration

box on
hold on

for j = 1:1000
    ax_j = cell2mat(ddxdtt(iL_sort(j)));
    ay_j = cell2mat(ddydtt(iL_sort(j)));
    a_j = sqrt(ax_j.^2 + ay_j.^2);
    u_j = cell2mat(dxdt(iL_sort(j)));
    v_j = cell2mat(dydt(iL_sort(j)));
    V_j = sqrt(v_j.^2 + u_j.^2);
    xy = [norm_x{iL_sort(j)}' norm_y{iL_sort(j)}'];
    
    % color data:
    %     colo = [u_j;u_j]; % velocity
    colo = [a_j;a_j]/(sqrt(a_var)); % (normalized) acceleration magnitude
    
    surface([xy(:,1)';xy(:,1)'],[xy(:,2)';xy(:,2)'],colo,...
        'facecol','no',...
        'edgecol','interp',...
        'linew',2);
end
drawnow

%% plot normalized tracks, Nemes figure 8d
% limits on the colorbar:
clim = [0 2]; % coloring with velocity
% clim = [0 1]*3; % coloring with acceleration magnitude

figure
caxis([clim])
colormap(jet(64))
cb=colorbar('eastoutside','ticklabelinterpreter','latex');
xlabel('horizontal (px)','interpreter','latex','fontsize',12)
ylabel('vertical (px)','interpreter','latex','fontsize',12)
set(gca,'ticklabelinterpreter','latex')
axis equal tight
% label for colorbar:
ylabel(cb,'$v (px/dt)$','interpreter','latex','fontsize',12) % velocity
% ylabel(cb,'$|a| (px/dt^2)$','interpreter','latex','fontsize',12) % acceleration

box on
hold on

for j = 1:1000
    ax_j = cell2mat(ddxdtt(iL_sort(j)));
    ay_j = cell2mat(ddydtt(iL_sort(j)));
    a_j = sqrt(ax_j.^2 + ay_j.^2);
    u_j = cell2mat(dxdt(iL_sort(j)));
    v_j = cell2mat(dydt(iL_sort(j)));
    V_j = sqrt(v_j.^2 + u_j.^2);
    xy = [norm_x{iL_sort(j)}' y{iL_sort(j)}'];
    
    % color data:
    colo = [v_j;v_j]; % velocity
    %     colo = [a_j;a_j]/(sqrt(a_var)); % (normalized) acceleration magnitude
    
    surface([xy(:,1)';xy(:,1)'],[xy(:,2)';xy(:,2)'],colo,...
        'facecol','no',...
        'edgecol','interp',...
        'linew',2);
end
drawnow

%% acceleration statistics, Nemes figure 10a and b
[h_counts_a,h_edges_a] = histcounts(a,[0:sqrt(var(a,0))/2:ceil(max(a))]); % This is basically histcounts(variable, 1st bin: bin size: last bin) and histcounts is counting how many of a is in each bin
%h_counts_a is outputting that into a vector. h_edges_a is just spitting
%back out the edges that you set in histcounts.
h_logedges = [.25:.5:2.75 logspace(log10(3.25),log10(20),8)]; %concatenating a vector to who a tail on the left with a logspace vector that is the same as the bin edge size for the PDF
h_edges = [-fliplr(h_logedges) h_logedges]; %fliplr flips an array from left to right. This line just makes it so you have plus or minus of h_lodges on both sides of 0.
h_centers = h_edges(2:end)/2+h_edges(1:end-1)/2; %this is finding the center of each bin
h_width = h_edges(2:end)-h_edges(1:end-1); %Finding the width of each bin
[h_counts_ax,h_edges_ax] = histcounts(ax/sqrt(var(ax,0)),h_edges); %normalizing by the standard deviation?
[h_counts_ay,h_edges_ay] = histcounts(ay/sqrt(var(ay,0)),h_edges); %normalizing by the standard deviation?

ax_rn = randn(1,1E6);
[h_counts_ax_rn,h_edges_ax_rn] = histcounts(ax_rn,[-5:.1:5]);
ay_rn = randn(1,1E6);
[h_counts_ay_rn,h_edges_ay_rn] = histcounts(ay_rn,[-5:.1:5]);
a_rn = sqrt(ax_rn.^2+ay_rn.^2);
[h_counts_a_rn,h_edges_a_rn] = histcounts(a_rn,[0:.1:6]);

s = .8;
m = sqrt(3/exp(2*s^2));
xa = 0:.1:10;
f_xa = exp(s^2/2)/(4*m)*(1-erf((log(xa/m)+s^2)/(sqrt(2)*s)));
figure
plot(-10:.1:10,normpdf(-10:.1:10,0,1),'-k')
hold on
ylim([1E-7 1E0])
xlim([-20 20])
p2=plot(h_centers,h_counts_ax./(h_width*sum(h_counts_ax)),'>','linewidth',1.5,'markersize',4);
p3=plot(h_centers,h_counts_ay./(h_width*sum(h_counts_ay)),'v','linewidth',1.5,'markersize',4);
set(gca,'yscale','log','ticklabelinterpreter','latex','fontsize',14)
xlabel('$a/\sqrt{\langle a''^2\rangle}$','interpreter','latex')
ylabel('PDF','interpreter','latex')

le = legend([p2 p3],'$a_x$','$a_y$');
set(le,'interpreter','latex','fontsize',13)

figure
hold on
box on
set(gca,'ColorOrderIndex',4)
plot((0.5*h_edges_a(2:end)+0.5*h_edges_a(1:end-1))/sqrt(var(a,0)),h_counts_a/(sqrt(var(a,0))/2/sqrt(var(a,0))*sum(h_counts_a)),'s','linewidth',1.5)
xlabel('a/(a'')^{0.5}')
ylabel('PDF')
set(gca,'yscale','log')
plot(0:.02:20,lognpdf(0:.02:20,-0.45,1),'-k')
ylim([1E-7 1E1])
xlim([0 35])