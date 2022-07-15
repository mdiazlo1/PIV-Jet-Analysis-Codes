function AdjustingImageBrightness(datdirec,datadirec,processeddirec)
j = 0;

for k = 1:numel(datadirec)
    clc;
    disp('Histogram matching the images')
    disp(['Run ' num2str(k) ' of ' num2str(numel(datadirec))])
    for m = 1:numel(datadirec{k})
        j = j+1;
        if ~exist([processeddirec '\HistMatchImages' '\R' num2str(j)],'dir')
            mkdir([processeddirec '\HistMatchImages' '\R' num2str(j)])
        end
        
        direc = [datdirec '\R' num2str(k) '\' datadirec{k}{m} '\Data Images'];
        A = dir([direc '\*.tiff']); Images = {};
        [Images{1:length(A),1}] = A.name; Images = sortrows(Images); clearvars A
        
        %% First look at what happens if we use imhistmatch to match the histogram of images
        
        img = zeros(250,400,'uint16'); BrightImageIndex = 1;
        %Load all of the images
        for i = 1:numel(Images) 
            temp = imread([direc '\' Images{i}]);
            temp = flip(temp,2);
            img(:,:,i) = temp;
            meanbright = mean(img(:,:,BrightImageIndex),'all');

            %Find image with max brightness
            meanImg = mean(img(:,:,i),'all');

            if meanImg > meanbright
                BrightImageIndex = i; %this is the index for the brightest image (image we want to match histogram with)
            end
        end
        adjustlow = 0.1; adjusthigh = 0.7;
        AdjustedImage = zeros(250,400,'uint16');
        for i = 1:numel(Images)
            AdjustedImage(:,:,i) = imadjust(imhistmatch(img(:,:,i),img(:,:,BrightImageIndex)),[0 1]);

            if mean(img(:,:,BrightImageIndex),'all') > 2e4
                AdjustedImage(:,:,i) = imadjust(imhistmatch(img(:,:,i),img(:,:,BrightImageIndex+1)),[adjustlow 1]);
            end

            if mean(img(:,:,BrightImageIndex),'all') < 1.5e4
                AdjustedImage(:,:,i) = imadjust(imhistmatch(img(:,:,i),img(:,:,BrightImageIndex)),[0 adjusthigh]);
            end
                
            imwrite(AdjustedImage(:,:,i),[processeddirec '\HistMatchImages' '\R' num2str(j) '\data_' sprintf('%03d',i) '.tiff'])
        end 
    end
end

    


end
    
