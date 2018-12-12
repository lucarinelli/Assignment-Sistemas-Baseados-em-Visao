% reset everything and close all open windows
clear all
close all
clc

%% load ground truth

load('ground_truth.mat')

%% load all the images

% Specify the folder where the images are
imagesFolder = 'hard';
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
    
    figure();
    %subplot(1,2,1);
    imshow(original);title('Original', 'FontSize', 15);  % Display image.
    figure();
    
    %no_noise = 
    
    % Contrast enhancement
    contrast = imadjust(original, stretchlim(original)); %%colored
    
    con_img_gray = rgb2gray(contrast); %%gray
    % con_img_gray = adapthisteq(con_img_gray);
    con_img_gray = imadjust(con_img_gray, stretchlim(con_img_gray));
    
    image_size=size(original);
    
    just_color_trhs = 10;
    whitish_trsh = 10;
    
    just_red = uint8(zeros(image_size(1:2)));
    just_blue = uint8(zeros(image_size(1:2)));
    just_whitish = uint8(zeros(image_size(1:2)));
    % just the stuff that's red or blue
    for i = 1:image_size(1)
        for j = 1:image_size(2)
            if contrast(i,j,1) > contrast(i,j,2) + just_color_trhs && contrast(i,j,1) > contrast(i,j,3) + just_color_trhs
                just_red(i,j) = contrast(i,j,1);
            end
        end
    end
    for i = 1:image_size(1)
        for j = 1:image_size(2)
            if contrast(i,j,3) > contrast(i,j,2) + just_color_trhs && contrast(i,j,3) > contrast(i,j,1) + just_color_trhs
                just_blue(i,j) = contrast(i,j,1);
            end
        end
    end
    for i = 1:image_size(1)
        for j = 1:image_size(2)
            if (abs(con_img_gray(i,j)-contrast(i,j,1))<whitish_trsh) && (abs(con_img_gray(i,j)-contrast(i,j,2))<whitish_trsh) && (abs(con_img_gray(i,j)-contrast(i,j,3))<whitish_trsh)
                just_whitish(i,j) = con_img_gray(i,j);
            end
        end
    end
    just_red2 = imsubtract(imsubtract(contrast(:,:,1),contrast(:,:,2)),contrast(:,:,3));
    just_blue2 = imsubtract(imsubtract(contrast(:,:,3),contrast(:,:,2)),contrast(:,:,1));
    % just_whitish = abs(contrast(:,:,1)-contrast(:,:,1)-contrast(:,:,1));
    
    % to highlight also dark stuff
    % TODO Loose the binarization to take more stuff
    %just_red = imbinarize(imadjust(just_red,stretchlim(just_red)));
    %just_blue = imbinarize(imadjust(just_blue,stretchlim(just_blue)));
    
    % clean some noise
    % just_red = imclose(imopen(just_red,strel('rectangle',[3 3])),strel('disk',2));
    % just_blue = imclose(imopen(just_blue,strel('rectangle',[3 3])),strel('disk',2));
    
    % find edges on gray
    edges = edge(con_img_gray,'canny');
%     [H,T,R] = hough(edges);
%     P  = houghpeaks(H,20,'threshold',ceil(0.05*max(H(:))));
%     lines = houghlines(edges,T,R,P,'FillGap',5,'MinLength',10);
    
    just_red_adj = imadjust(just_red,stretchlim(just_red));
    just_red2_adj = imadjust(just_red2,stretchlim(just_red2));
    just_red_bin = imbinarize(just_red_adj);
    just_red2_bin = imbinarize(just_red2_adj);
    subplot(1,2,1);imshow(just_red_adj)
    subplot(1,2,2);imshow(just_red2_adj)
    figure();
    just_blue_adj = imadjust(just_blue,stretchlim(just_blue));
    just_blue2_adj = imadjust(just_blue2,stretchlim(just_blue2));
    just_blue_bin = imbinarize(just_blue_adj);
    just_blue2_bin = imbinarize(just_blue2_adj);
    subplot(1,2,1);imshow(just_blue_adj)
    subplot(1,2,2);imshow(just_blue2_adj)
    figure();
    
    just_whitish_adj = imadjust(just_whitish,stretchlim(just_whitish));
    just_whitish_bin = imbinarize(just_whitish_adj);
    imshow(just_whitish_adj)
    figure();
    
    % put together red, blue and edges on green
    red_n_blue = cat(3,255*uint8(just_red_bin|just_whitish_bin),(edges|just_whitish_bin)*255,255*uint8(just_blue_bin|just_whitish_bin));
    
%     Rmin = 6;
%     Rmax = 100;
%     [centersRed, radiiRed] = imfindcircles(just_red_bin,[Rmin Rmax],'ObjectPolarity','bright');
%     [centersBlue, radiiBlue] = imfindcircles(just_blue_bin,[Rmin Rmax],'ObjectPolarity','bright');
    
    
    % plot da things
    %subplot(1,2,2);
    imshow(red_n_blue);title(strcat('Red&Blue edges in green ',fullFileName), 'FontSize', 15);
    %subplot(2,2,3);imshow(edge_gray);title('Edges gray', 'FontSize', 15);
    %subplot(2,2,4);imshow(just_blue);title('Blue', 'FontSize', 15);
    
%     hold on
%     max_len = 0;
%     for k = 1:length(lines)
%        xy = [lines(k).point1; lines(k).point2];
%        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%        % Plot beginnings and ends of lines
%        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%        % Determine the endpoints of the longest line segment
%        len = norm(lines(k).point1 - lines(k).point2);
%        if ( len > max_len)
%           max_len = len;
%           xy_long = xy;
%        end
%     end
    
%     viscircles(centersRed, radiiRed,'LineStyle','--');
%     viscircles(centersBlue, radiiBlue,'LineStyle','--');
    
    % draw ground truth
    hold on
    gt_index = find(strcmp({ground_truth.filename}, baseFileName)==1);
    gt_rectangles = ground_truth(gt_index).gt;
    for gti = 1 : size(gt_rectangles,1)
        px = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
        py = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
        patch(px, py,'White', 'FaceColor', [1,1,1], 'FaceAlpha', 0.5);
    end
    
    hold off
    
    %subplot(2,1,2);imshow(con_img)
    %con_img_gray = rgb2gray(con_img); %%gray
    %con_img_gray = imadjust(con_img_gray, stretchlim(con_img_gray));

    % BINARIZED PIC
    %bin_gray = im2bw(con_img_gray, 0.5);
    %bin = imbinarize(con_img);
    %figure()
    %imshowpair(bin_gray,bin,'montage')
    %title('Binarized (before opening) - gray vs color', 'FontSize', 15);

    %bin_gray=bwareaopen(bin_gray, 300); % o q � o 300?
    %bin=bwareaopen(bin, 300); 
    %figure()
    %imshowpair(bin_gray,bin,'montage')
    %title('Binarized (after opening) - gray vs color', 'FontSize', 15);
    
    drawnow; % Force display to update immediately.
end