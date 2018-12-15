function [bin_mask] = DefineCentralRegion(Image)
%pre processing of images to extract the mask
%------------------------------------------------------

bin_mask = Image;
CC = bwconncomp(bin_mask);
REGION2 = regionprops(CC);

    max_x =400;
    max_y =400;
    max_fin_x = 0;
    max_fin_y = 0;
    boundary_x = zeros(length(REGION2),1);
    boundary_y = zeros(length(REGION2),1);
    boundary_fin_x = zeros(length(REGION2),1);
    boundary_fin_y = zeros(length(REGION2),1);
    n_cerchi = 0;
    
   
for k =1:length(REGION2)
    
    area = REGION2(k).Area;
    data_bounding = REGION2(k).BoundingBox;
    start_x = floor(data_bounding(1));
    start_y = floor(data_bounding(2));
    lungh = data_bounding(3);
    alt = data_bounding(4);  
    
    
    if start_x > 100 && start_x + lungh < 350
        if start_y > 100 && start_y + alt < 350
                       
            if start_x < max_x
                max_x = start_x;
            end
            if start_y < max_y
                max_y = start_y;               
            end
            if (start_x + lungh) > max_fin_x 
                max_fin_x = (start_x + lungh) ;
            end
            if (start_y + alt) > max_fin_y 
                max_fin_y = (start_y + alt);
            end
        else 
            boundary_x(k) = 400;
            boundary_y(k) = 400;
            boundary_fin_x = 0;
            boundary_fin_y = 0;
        end
    end
end
for u = 1 : max_x
     for y = 1 : 400 
         bin_mask(y,u) = 0;
     end
    end
for u = max_fin_x+1 : 400
     for y = 1 : 400 
         bin_mask(y,u) = 0;
     end
end
for u = 1 : 400
     for y = 1 : max_y 
         bin_mask(y,u) = 0;
     end
end
for u = 1 : 400
     for y = 1+max_fin_y : 400 
         bin_mask(y,u) = 0;
     end
end
step1 = bin_mask;
area_max = 0;
% if (max_fin_x-max_x) > 0 && (max_fin_y-max_y) > 0
%     rectangle('Position', [max_x,max_y,max_fin_x-max_x, max_fin_y-max_y],...
%     'EdgeColor','r','LineWidth',2 );
% end;
end