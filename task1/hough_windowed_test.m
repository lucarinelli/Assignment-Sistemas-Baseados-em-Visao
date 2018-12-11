close all
clear all

original = imread('images/test.png');

figure();
imshow(original);

just_red = createMaskRed(original);

figure();
imshow(just_red);

fill_red = bwmorph(just_red,'fill');
thin_red = bwmorph(fill_red,'thin',Inf);
edge_red = edge(fill_red);

figure();
imshow(edge_red);

lines=[];

for j=0:16 % slide horizontaly
    for i=0:9 % slide vertically
        [H,T,R] = hough(thin_red((i*80+1):((i+2)*80-1), (j*80+1):((j+2)*80-1)));
        P  = houghpeaks(H,25,'threshold',ceil(0.8*max(H(:))));
        lines_temp = houghlines(thin_red,T,R,P,'FillGap',5,'MinLength',15);
        lines=[lines;lines_temp'];
    end
end

figure, imshow(thin_red), hold on
max_len = 1500;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end