outer_rad = 20;
center = outer_rad; 
mask1_size = center*2;

[x,y] = meshgrid(1:mask1_size-1,1:mask1_size-1);

distance = (x-center).^2+(y-center).^2;
circ_mask = distance<outer_rad^2;