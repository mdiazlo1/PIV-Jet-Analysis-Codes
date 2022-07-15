function EliminateDarkImages(datdirec,datadirec,processeddirec)
    
tic
for k = 1:numel(datadirec)
    clc;
    disp('Taking out all dark images...')
    disp(['Run ' num2str(k) ' of ' num2str(numel(datadirec))])
    for m = 1:numel(datadirec{k})
        if ~exist([datdirec '\R' num2str(k) '\' datadirec{k,1}{m} '\Data Images'],'dir')
            mkdir([datdirec '\R' num2str(k) '\' datadirec{k,1}{m} '\Data Images'])
        end

        %load all images
        j = 0;
        iold = 0;
        for i = 1:256
            temp = imread([datdirec '\R' num2str(k) '\' datadirec{k,1}{m} '\' datadirec{k,1}{m} '_' sprintf( '%03d', i) '.tiff']);
            T = find(imbinarize(temp, 0.2));
            if ~isempty(T) && std(double(temp),0,'all') > 6000
                j = j+1;
                if j == 1
                    iold = i;
                    imwrite(temp, [datdirec '\R' num2str(k) '\' datadirec{k,1}{m} '\Data Images\data_' sprintf( '%03d', j) '.tiff'])
                elseif i == iold + 1
                    imwrite(temp, [datdirec '\R' num2str(k) '\' datadirec{k,1}{m} '\Data Images\data_' sprintf( '%03d', j) '.tiff'])
                    iold = i;
                else
                    j = 1;
                    iold = i;
                    if ~exist([datdirec '\R' num2str(k) '\' datadirec{k,1}{m} '\Data Images'],'dir')
                        mkdir([datdirec '\R' num2str(k) '\' datadirec{k,1}{m} '\Data Images'])
                    end
                    imwrite(temp,[datdirec '\R' num2str(k) '\' datadirec{k,1}{m} '\Data Images\data_' sprintf( '%03d', j) '.tiff'])
                end

            end
        end
    end
end
    toc


end