function [bin_mask] = AreaConstraint(Image,LimitArea)
%pre processing of images to extract the mask
%------------------------------------------------------

bin_mask = Image;
CC = bwconncomp(bin_mask);
REGION = regionprops(CC,'Area','BoundingBox','Perimeter');
step1 = bin_mask;
 for k =1:length(REGION)
    area = REGION(k).Area;
    data_bounding = REGION(k).BoundingBox;
    start_x = data_bounding(1);
    start_y = data_bounding(2);
    lungh = data_bounding(3);
    alt = data_bounding(4);
    
%% area constraint
if area < LimitArea

%    thisBB = REGION(k).BoundingBox;
%    rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
%    'EdgeColor','r','LineWidth',2 );

for u = floor(start_x):floor(start_x+lungh)
     for y = floor(start_y) : floor(start_y+alt);
         bin_mask(y,u) = 0;
     end
end
end

 end;
end