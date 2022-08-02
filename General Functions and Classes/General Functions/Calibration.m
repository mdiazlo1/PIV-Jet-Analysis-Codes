% a = imread('C:\Users\mxdni\Johns Hopkins\Juan Sebastian Rubio - Plume-Surface Interaction Research Group\1. Projects\PFGT\2021_04_15\T4\V2511_Mirror');
function dperPix = Calibration(data_dir)
C = imread(data_dir);

imshow(C)

x(1,:) = ginput(1);
hold on
plot(x(1,1),x(1,2))
pause
x(2,:) = ginput(1);

prompt = {'Distance between clicks?'};
dlgtitle = 'Calibration';
dims = [1 45];
distance = str2double(inputdlg(prompt,dlgtitle,dims));

deltax = x(1,1)-x(2,1);
deltay = x(1,2)-x(2,2);

Ddelta = sqrt((deltax^2)+(deltay^2));
dperPix = distance/Ddelta;
end



