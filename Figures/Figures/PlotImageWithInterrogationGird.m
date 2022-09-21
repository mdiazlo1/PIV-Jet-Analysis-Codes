close all
IntWinSize = 16;

imshow(data_003)
hold on
[rows, columns, numberOfColorChannels] = size(data_003);
for row = 1 : IntWinSize : rows
  line([1, columns], [row, row], 'Color', 'r');
end
for col = 1 : IntWinSize : columns
  line([col, col], [1, rows], 'Color', 'r');
end