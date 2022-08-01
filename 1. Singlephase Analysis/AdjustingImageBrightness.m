function AdjustingImageBrightness(datdirec,datadirec,processeddirec)
j = 0;

for k = 1:numel(datadirec)
    for m = 1:numel(datadirec{k})
    clc;
    disp('Histogram matching the images')
    disp(['Run ' num2str(k) ' of ' num2str(numel(datadirec))])
        j = j+1;
        if ~exist([processeddirec '\HistMatchImages' '\R' num2str(j)],'dir')
            mkdir([processeddirec '\HistMatchImages' '\R' num2str(j)])
        end
        
        direc = [datdirec filesep 'R' num2str(k) filesep datadirec{k}{m} '\Data Images'];
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
        AdjustedImage = zeros(250,400,'uint16');
     
        for i = 1:numel(Images)
            if i ~= BrightImageIndex
                AdjustedImage(:,:,i) = imhistmatch(img(:,:,i),img(:,:,BrightImageIndex));
            else
                AdjustedImage(:,:,i) = img(:,:,i);
            end
            
            imwrite(AdjustedImage(:,:,i),[processeddirec '\HistMatchImages' '\R' num2str(j) '\data_' sprintf('%03d',i) '.tiff'])
           
        end 
    end
end

    


end
    
