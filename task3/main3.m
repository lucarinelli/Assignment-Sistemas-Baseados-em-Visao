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

for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imagesFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    
    
    original = imread(fullFileName);
    imagesize = size(original);
    max_x = imagesize(1)/2;
    max_y = imagesize(2)/2;
    original1 = imcrop(original, [max_x-15 max_y-15 max_x+12 max_y+12]);
    
     %subplot(1,2,1);imshow(original);title('norm', 'FontSize', 15);
     %subplot(1,2,2);imshow(original1);title('crop', 'FontSize', 15);
    
    % Contrast enhancement
    contrast = imadjust(original1, stretchlim(original1)); %%colored 
    
    contrast2 = histeq(contrast,2);
    sharp = imsharpen(contrast2);
    
    con_img_gray = rgb2gray(sharp); %%gray
    %con_img_gray = imadjust(con_img_gray, stretchlim(con_img_gray)); %increase contrast
    bina_filt = imbinarize(histeq(con_img_gray,5),'adaptive','sensitivity',0.68); %binarization
    subplot(1,2,1);imshow(con_img_gray);title('crop', 'FontSize', 15);
    subplot(1,2,2);imshow(bina_filt);title('contrast', 'FontSize', 15);figure
    
    bina_filt = bwmorph(bina_filt,'thicken');
    
    se = strel('square',2);
    bina_filt = imerode(bina_filt,se); %morphology adjustment
%     bina_filt = bwmorph(bina_filt,'hbreak');
%     bina_filt = bwmorph(bina_filt,'spur');

    %bina_filt = bwmorph(bina_filt,'open');
    
%       se = strel('square',1);
%       bina_filt = imopen(bina_filt,se); %morphology adjustment
%     subplot(1,2,1);imshow(bina);title('bina', 'FontSize', 15);
%     subplot(1,2,2);imshow(bina_filt);title('bina_filt', 'FontSize', 15);figure
    edges = edge(bina_filt, 'canny');
%     subplot(1,2,1);imshow(edges);title('edge', 'FontSize', 15);
%     subplot(1,2,2);imshow(bina_filt);title('bina_filt', 'FontSize', 15);figure
    
 
%     [H, T, R] = hough(bina_filt);
%     P = houghpeaks(H,4);
%     lines = houghlines(bina_filt,T,R,P)
%     %edge_bin = edge(bina_filt, 'canny',);
%     %imshow(edge_bin);figure
%     figure, imshow(bina_filt), hold on
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
%        end
%  
%        % highlight the longest line segment
%        plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');
   
    image_size=size(original);
    just_red = uint8(zeros(image_size(1:2)));
    just_blue = uint8(zeros(image_size(1:2)));
    just_whitish = uint8(zeros(image_size(1:2)));
    

    %[A,B] = mascheraB(original);
    %imshow(A);figure
%     just_whitish_adj = imadjust(just_whitish,stretchlim(just_whitish));
%     just_whitish_bin = imbinarize(just_whitish_adj);
%     w_edge = edge(just_whitish_bin, 'canny');figure
    %imshow(w_edge);title('white', 'FontSize', 15);


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
%     drawnow; % Force display to update immediately.
end