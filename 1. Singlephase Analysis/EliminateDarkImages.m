function EliminateDarkImages(datdirec,datadirec,processeddirec)
    
tic
for k = 1:numel(datadirec)
    clc;
    disp('Taking out all dark images...')
    disp(['Run ' num2str(k) ' of ' num2str(numel(datadirec))])
    if ~exist([datdirec filesep datadirec{k} '\Data Images'],'dir')
        mkdir([datdirec filesep datadirec{k} '\Data Images'])
    end

    %load all images
    j = 0;
    iold = 0;
    for i = 1:256
        temp = imread([datdirec filesep datadirec{k} '\' datadirec{k} '_' sprintf( '%03d', i) '.tiff']);
        T = find(imbinarize(temp, 0.2));
        if ~isempty(T) && std(double(temp),0,'all') > 3000
            j = j+1;
            if j == 1
                iold = i;
                imwrite(temp, [datdirec filesep datadirec{k} '\Data Images\data_' sprintf( '%03d', j) '.tiff'])
            elseif i == iold + 1
                imwrite(temp, [datdirec filesep datadirec{k} '\Data Images\data_' sprintf( '%03d', j) '.tiff'])
                iold = i;
            else
                j = 1;
                iold = i;
                if ~exist([datdirec filesep datadirec{k} '\Data Images'],'dir')
                    mkdir([datdirec filesep datadirec{k} '\Data Images'])
                end
                imwrite(temp,[datdirec filesep datadirec{k} '\Data Images\data_' sprintf( '%03d', j) '.tiff'])
            end

        end
    end
end
    toc


end