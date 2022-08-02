function Mask = DetermineMask(processeddirec)
    temp = imread([processeddirec '\R1\data_004.tiff']);
    imshow(temp)
    [~,Mask{1,1},Mask{1,2}]=roipoly;
end
