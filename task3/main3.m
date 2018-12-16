% reset everything and close all open windows
clear all
close all
clc

%% load ground truth-------------------------------------------------------

load('ground_truth_3.mat')

%% training

directories = {'trafficlight'; 'bottleneck'; 'leftcurve'; 'rightcurve'; 'crossroad'; 'scurve'; 'snow'; 'esclamationpoint'};
datas = TrainingData(directories);




% %% load all the images-----------------------------------------------------
% % Specify the folder where the images are
% imageFolder = 'danger';
% % Check to make sure that folder actually exists.  Warn user if it doesn't.
% if ~isdir(imageFolder)
%     errorMessage = sprintf('Error: The following folder does not exist:\n%s', imageFolder);
%     uiwait(warndlg(errorMessage));
%     return;
% end
% % Get a list of all files in the folder with the desired file name pattern.
% filePattern = fullfile(imageFolder, '*.png');
% theFiles = dir(filePattern);
% 
% %% analyze images----------------------------------------------------------
% for k = 1 : length(theFiles)
%     baseFileName = theFiles(k).name;
%     fullFileName = fullfile(imageFolder, baseFileName);
%     fprintf(1, 'Now reading %s\n', fullFileName);
%     
%     % Now do whatever you want with this file name,
%     % such as reading it in as an image array with imread()
%     
%     %% Preprocessing-----------------------------------------------------------
%     original = imread(fullFileName);
%     bin_mask = Preprocessing(original);
%     
%     
%     %% find regions (REGION PROMPS)--------------------------------------------
%     smallestArea = 16000*0.03;
%     bin_mask = AreaConstraint(bin_mask,smallestArea);
%     
%     %% regionprops define rectangle of interest--------------------------------
%     bin_mask = DefineCentralRegion(bin_mask);
%     
%     %% again area contraint----------------------------------------------------
%     step1 = bin_mask;
%     minArea = 700;
%     bin_mask = AreaConstraint(bin_mask,minArea);
%     % figure();
%     %     subplot(1,2,1);imshow(bin_mask);title('bin_mask');
%     %     subplot(1,2,2);imshow(step1);title('step1');
%     
%     
%     %% starting classification-------------------------------------------------
%     % figure();imshow(bin_mask);
%     CC1 = bwconncomp(bin_mask);
%     classification = regionprops(CC1,'BoundingBox', 'centroid','area','Eccentricity');
%     for qq=1: length(classification)
%         thisBB = classification(qq).BoundingBox;
%         %    rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
%         %    'EdgeColor','r','LineWidth',2 );    
%     end
%   
    
    
    
    
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
% end