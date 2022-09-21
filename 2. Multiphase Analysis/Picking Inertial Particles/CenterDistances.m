clear all; 
NBins = 50;
% if P0 == 50
%     Dates = ['2022_06_30';'2022_07_01';'100 micron';'']
% elseif P0 == 95
%     
% end

% for j = 1:numel(Dates)

    direc = DirectoryAssignment('E:\PIV Data','2022_06_27',3,0,0);

    [~,processeddirec,analyzeddirec] = direc.GeneratePaths();


    load([analyzeddirec '\LPTData.mat'])
    
    centers = CenterSave;

    dperPix = 6.625277859765377e-06;
    ParticleRadius = 100e-6;

%     DistPerRun = zeros(1,numel(centers));
%     for i = 1:numel(centers)
%         DistPerRun(i) = pdist(centers{i});
%     end
%     MeanDist = mean(DistPerRun,'omitnan')

      Distances = cell2mat(cellfun(@pdist,centers,'UniformOutput',false));
      edges = linspace(0,sqrt(400^2+250^2),NBins);
      [Counts,h_edges] = histcounts(Distances,edges,'normalization','pdf');
      hcenters = 0.5*(h_edges(1:end-1)+h_edges(2:end));

      plot(hcenters,Counts)
      

    Distances = cellfun(@pdist,centers,'UniformOutput',false);
    
    edges = linspace(0,sqrt(400^2+250^2),NBins);
    [Counts,h_edges] = cellfun(@histcounts,Distances,repmat({edges},1,numel(Distances)),'UniformOutput',false);
    BinWidth = cellfun(@(x) x(2)-x(1),h_edges,'UniformOutput',false);
    hcenters = cellfun(@(x) 0.5*(x(1:end-1)+x(2:end)),h_edges,'UniformOutput',false);
    
    ParticleNum = cellfun(@size,centers,repmat({1},1,numel(centers)),'UniformOutput',false);
    NormCounts = cellfun(@(x,y) x./(y/(pi*(343/2)^2)),Counts,ParticleNum,'UniformOutput',false); %343 is equivalent diameter for 450x250
    
    for i = 1:numel(NormCounts)
        NormCountsMat(:,:,i) = NormCounts{i};
    end

    NormCountsMean = sum(NormCountsMat,3,'omitnan');
    figure
    plot(hcenters{1},NormCountsMean)

    PrettyFigures(2,24,2)
% 
% 
% 
% 
% % ParticleNum = mean(ParticleNumConc(ParticleNumConc>0));
% % ParticleToFOV = ParticleNum*pi*ParticleRadius^2/(400*250*dperPix^2)