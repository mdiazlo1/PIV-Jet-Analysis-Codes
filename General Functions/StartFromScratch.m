function StartFromScratch(datdirec,datadirec,processeddirec,phasetype)
if phasetype == "Multiphase"
for k = 1:numel(datadirec)
    for m = 1:numel(datadirec{k})
        if exist([datdirec '\R' num2str(k) '\' datadirec{k,1}{m} '\Data Images'],'dir')
            cmd_rmdir([datdirec '\R' num2str(k) '\' datadirec{k,1}{m} '\Data Images'])
        end
    end
end
end

if phasetype == "Singlephase"
for k = 1:numel(datadirec)
    for m = 1:numel(datadirec{k})
        if exist([datdirec filesep datadirec{k} '\Data Images'],'dir')
            cmd_rmdir([datdirec filesep datadirec{k} '\Data Images'])
        end
    end
end

if exist(processeddirec,'dir')
    cmd_rmdir(processeddirec)
end
end