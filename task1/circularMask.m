function [BW] = circularMask(center,radius,size)

[x,y] = meshgrid(1:size(2),1:size(1));

distance = (x-center(1)).^2+(y-center(2)).^2;
BW = distance<radius^2;

end