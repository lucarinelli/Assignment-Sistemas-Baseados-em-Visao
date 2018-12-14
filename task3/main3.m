% reset everything and close all open windows
clear all
close all
clc

%% load ground truth

load('ground_truth_3.mat')

%% load all the images
% Specify the folder where the images are
imagesFolder = 'danger';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(imagesFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', imagesFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(imagesFolder, '*.png');
theFiles = dir(filePattern);
somma = 0;
%% analyze images 
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imagesFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()

    
    original = imread(fullFileName);
    
    resized = imresize(original,[400 400],'bilinear');  %resize
    resized2 = imsharpen(resized);
    gray = rgb2gray(resized2);
    gray_filt = medfilt2(gray);
    tria_mask2 = roipoly(gray,[size(gray,2)/2 1 size(gray,2)],[1 size(gray,1) size(gray,1)]);
    

    
    
    [r c] = size(gray_filt);
    mean = mean2(gray_filt(100:300,100:300));
 
    %if the image is too dark, it increases contrast  
    if mean <=40
        gray_filt = adapthisteq(gray_filt, 'ClipLimit' ,0.01,'NumTiles',[4 4]);     
    end   
    
%     
%     if average >50 && average<100
%         for m=1:r
%             for l=1:c
%         eqi(m,l) = eqi(m,l)+19;
%             end
%         end
%     end
%---------------------------------------------------------    
    
 
 step1 = gray_filt;
 
    for m=1:r
        for l=1:c
        if gray_filt(m,l) >=215 && gray_filt(m,l)<=255
            gray_filt(m,l) = 255;
        else
            gray_filt(m,l) = gray_filt(m,l);
            
        end
        end
    end
 
%     bin = imbinarize(step1);
%     resized_eq2 = adapthisteq(gray_filt, 'ClipLimit' ,0.01,'NumTiles',[4 4]);
%     bin2 = imbinarize(resized_eq2);
    resized_eq3 = adapthisteq(gray_filt, 'ClipLimit' ,0.01);
    bin3 = imbinarize(resized_eq3); %binarization
    bin3_compl = imcomplement(bin3);
    bin_mask = bin3_compl.*tria_mask2;
%     bin4 = imbinarize(gray_filt);
  

%      figure();
%     subplot(3,3,1);imshow(step1);title('step1', 'FontSize', 15);
%     subplot(3,3,2);imshow(bin4);title('bin4', 'FontSize', 15);
%      subplot(3,3,3);imshow(bin3.*tria_mask2);title('bin3', 'FontSize', 15);
%     subplot(3,3,4);imshow(gray);title('gray', 'FontSize', 15);
%     subplot(3,3,5);imshow(bin);title('bin step1', 'FontSize', 15);
%     subplot(3,3,6);imshow(bin2);title('bin2', 'FontSize', 15); 
    
    
    
    

     
%% find regions (REGION PROMPS)----------------------------------------------
%figure();imshow(bin_mask);
CC = bwconncomp(bin_mask);
[BBB, LLL, NNN] = bwboundaries(bin_mask);
figure();imshow(label2rgb(LLL));
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
if area < (16000*0.03)

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

 
 %% regionprops (perimeter)

    
figure();imshow(bin_mask);
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
% if (max_fin_x-max_x) > 0 && (max_fin_y-max_y) > 0
%     rectangle('Position', [max_x,max_y,max_fin_x-max_x, max_fin_y-max_y],...
%     'EdgeColor','r','LineWidth',2 );
% end;

%% after found the region of interest, we delete everything that is not inside it
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

CC = bwconncomp(bin_mask);
REGION3 = regionprops(CC);

for k =1:length(REGION3)
    area = REGION3(k).Area;
    data_bounding = REGION3(k).BoundingBox;
    start_x = data_bounding(1);
    start_y = data_bounding(2);
    lungh = data_bounding(3);
    alt = data_bounding(4);
    
    if area < 500
    for u = floor(start_x):floor(start_x+lungh)
     for y = floor(start_y) : floor(start_y+alt);
         bin_mask(y,u) = 0;
     end
end
    end
end

% %% regionprops Convexhull
% CC = bwconncomp(bin_mask);
% REGION4 = regionprops(CC, 'ConvexHull');
% points = cat(1,REGION4.ConvexHull);
% regionroi = roipoly(gray,points(:,1),points(:,2));


% figure();
% subplot(1,2,1);imshow(bin_mask);title('bin_mask');
% subplot(1,2,2);imshow(step1);title('step1');
    
%     
% drawnow;









 
%   figure();
%   subplot(3,3,1);imshow(step1);title('step1', 'FontSize', 15);
%   subplot(3,3,2);imshow(bin_mask);title('bin_mask', 'FontSize', 15);
% subplot(3,3,3);imshow(bin_mask);title('bin_mask', 'FontSize', 15);
% subplot(3,3,4);imshow(dilate);title('dilate', 'FontSize', 15);
% subplot(3,3,4);imshow(bin_mask);title('step1', 'FontSize', 15);
% subplot(3,3,5);imshow(bin_mask);title('step1', 'FontSize', 15);
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 %% -----morphological operation------WE DON'T NEED--------------------------
%     se=strel('square',5);
%     eros = imerode(bin3,[0 1 1 0;0 1 1 0;0 1 1 0;0 1 1 0]);
%     dilate = imdilate(bin3,se);
%     morpo = bwmorph(dilate,'spur');
%     se=strel('square',12);
%     morpo1 = imopen(morpo,se);
 
%     K = imcomplement (morpo1);
%     imagesize = size(morpo1);
%     max_x = imagesize(1)/2;
%     max_y = imagesize(2)/2;
%     cut = imcrop(morpo1, [max_x-max_x/2 max_y-max_y/2 max_x+8 max_y+12]);    
    
%% -----segmentation-------------WE DON'T NEED THIS-----------------------------
%     edges = edge(bin_mask, 'canny');
%      se=strel('square',5);
%      dilate = imdilate(edges,se);

 %% new regionprops boundary
%figure();imshow(bin_mask);
% edges = edge(bin_mask, 'canny');
% bin_mask = imbinarize(bin_mask);
% sub_bin_mask = imsubtract(bin_mask,edges);
% se=strel('square',5);
% bin_mask = imerode(sub_bin_mask,se);
% 
% CC = bwconncomp(bin_mask);
% REGION = regionprops(CC);
% step1 = bin_mask;
% % 
%  for k =1:length(REGION)
%     area = REGION(k).Area;
%     data_bounding = REGION(k).BoundingBox;
%     start_x = data_bounding(1);
%     start_y = data_bounding(2);
%     lungh = data_bounding(3);
%     height = data_bounding(4);
%      if area < (16000*0.03)
% for u = floor(start_x):floor(start_x+lungh)
%      for y = floor(start_y) : floor(start_y+height);
%          bin_mask(y,u) = 0;
%      end
% end
% end
% %  thisBB = REGION(k).BoundingBox;
% %   rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
% %   'EdgeColor','r','LineWidth',2 );
%  end
%  
 
% figure, imshow(bin_mask);
% if 
%  rectangle('Position',[REGION.BoundingBox(1),REGION.BoundingBox(2),REGION.BoundingBox(3),st.BoundingBox(4)],...
% 'EdgeColor','r','LineWidth',2 );






%% find lines with Hough transfomation
%     [H, T, R] = hough(dilate);
%     P = houghpeaks(H,4);
%     lines = houghlines(dilate,T,R,P);
%     figure();
%     imshow(dilate);
%     hold on
%        max_len = 0;
%        for k = 1:length(lines)
%          xy = [lines(k).point1; lines(k).point2];
%          plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
%  
%          % plot beginnings and ends of lines
%          plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%          plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
%  
% %          determine the endpoints of the longest line segment 
% %          len = norm(lines(k).point1 - lines(k).point2);
% %          if ( len > max_len)
% %            max_len = len;
% %            xy_long = xy;
% %          end
%         end
 
%        % highlight the longest line segment
%        plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');
   
%% groundtruth
%    %%Grountruth
%         % draw ground truth
%     hold on
%     gt_index = find(strcmp({ground_truth.filename}, baseFileName)==1);
%     gt_rectangles = ground_truth(gt_index).gt;
%     for gti = 1 : size(gt_rectangles,1)
%         px = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
%         py = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
%         patch(px, py,'White', 'FaceColor', [1,1,1], 'FaceAlpha', 0.5);
%     end
%     
%     hold off
%     
%     %subplot(2,1,2);imshow(con_img)
%     %con_img_gray = rgb2gray(con_img); %%gray
%     %con_img_gray = imadjust(con_img_gray, stretchlim(con_img_gray));
% 
%     % BINARIZED PIC
%     %bin_gray = im2bw(con_img_gray, 0.5);
%     %bin = imbinarize(con_img);
%     %figure()
%     %imshowpair(bin_gray,bin,'montage')
%     %title('Binarized (before opening) - gray vs color', 'FontSize', 15);
% 
%     %bin_gray=bwareaopen(bin_gray, 300); % o q � o 300?
%     %bin=bwareaopen(bin, 300); 
%     %figure()
%     %imshowpair(bin_gray,bin,'montage')
%     %title('Binarized (after opening) - gray vs color', 'FontSize', 15);
%     
%    drawnow; % Force display to update immediately.
 end