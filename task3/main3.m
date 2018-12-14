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
%     bin4 = imbinarize(gray_filt);
    
    
    
%     figure();
%     subplot(3,3,1);imshow(step1);title('step1', 'FontSize', 15);
%     subplot(3,3,2);imshow(bin4);title('bin4', 'FontSize', 15);
%     subplot(3,3,3);imshow(bin3);title('bin3', 'FontSize', 15);
%     subplot(3,3,4);imshow(gray);title('gray', 'FontSize', 15);
%     subplot(3,3,5);imshow(bin);title('bin step1', 'FontSize', 15);
%     subplot(3,3,6);imshow(bin2);title('bin2', 'FontSize', 15); 
    
    
    
    
%-----morphological operation------WE DON'T NEED--------------------------
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
    
%-----segmentation---------------------------------------------------
    edges = edge(bin3, 'canny');
     se=strel('square',5);
     dilate = imdilate(edges,se);
     
%     eros = imerode(edges,[0 1 1 0;0 1 1 0;0 1 1 0;0 1 1 0]);
%     morpo = bwmorph(edges,'spur');
%     se=strel('square',8);
%     morpo1 = imopen(edges,se);
    
   
     figure();
     subplot(3,3,1);imshow(eros);title('eros', 'FontSize', 15);
     subplot(3,3,2);imshow(gray_filt);title('gray_filt', 'FontSize', 15);
     subplot(3,3,3);imshow(morpo);title('morpo', 'FontSize', 15);
     subplot(3,3,4);imshow(edges);title('edges', 'FontSize', 15);
     subplot(3,3,5);imshow(dilate);title('dilate', 'FontSize', 15);
     subplot(3,3,6);imshow(morpo1);title('morpo1', 'FontSize', 15); 
%     
   
%     [B,L] = bwboundaries (morpo1 ,'noholes');
%     imshow (cut);
%     hold on
%     for k = 1: length (B)
%     boundary = B{k};
%     plot ( boundary (: ,2) ,boundary (: ,1) ,'g','LineWidth' ,2) ;
%     end    

    
 
%     [H, T, R] = hough(morpo1);
%     P = houghpeaks(H,4);
%     lines = houghlines(morpo1,T,R,P);
%     figure();
%     imshow(morpo1);
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
%          % determine the endpoints of the longest line segment 
%          len = norm(lines(k).point1 - lines(k).point2);
%          if ( len > max_len)
%            max_len = len;
%            xy_long = xy;
%          end
%         end
%  
%        % highlight the longest line segment
%        plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');
   

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