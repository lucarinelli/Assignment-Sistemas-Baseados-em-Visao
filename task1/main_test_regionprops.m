% reset everything and close all open windows
clear all
close all
clc

%% load ground truth

load('ground_truth.mat')

%% load all the images

% Specify the folder where the images are
imagesFolder = 'some';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(imagesFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', imagesFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(imagesFolder, '*.png');
theFiles = dir(filePattern);

fprintf(1, '----------------------------------\n %d IMAGES TO BE READ\n----------------------------------\n', length(theFiles));

total_signs_true_positive = 0;
total_signs_positive = 0;
total_signs_truth = 0;

for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imagesFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    original = imread(fullFileName);
    original_size = size(original);
    
    original_hsv = rgb2hsv(original);
    
    gray = rgb2gray(original);
    gray_hsv = rgb2gray(original_hsv);
    
    %figure();imshow(original);title('Original', 'FontSize', 15); % Display image.
    
    edges = edge(gray,'canny');
    thicken_edges = imdilate(edges,strel('disk',2));%bwmorph(edges,'thicken',2);
    just_red = createMaskRed(original).*(not(thicken_edges));
    just_blue = createMaskBlue(original).*(not(thicken_edges));
    just_whitish = createMaskWhitish(original);
    
    
    %figure; imshow(just_whitish);title('W', 'FontSize', 10); % Display image.
    %figure; imshow(just_red);title('R', 'FontSize', 10); % Display image.
    %figure; imshow(just_blue);title('B', 'FontSize', 10); % Display image.
    
    all_masks = cat(3,255*uint8(just_red),edges,255*uint8(just_blue));
    
    
    signs_founded = [];
    
    %% REGIONPROPS STUFF
    
    %get outlines of each object
    [B,L,N] = bwboundaries(just_blue);
    %get stats
    stats =  regionprops(L,'BoundingBox');
    BBox = cat(1,stats.BoundingBox);

    hypothesis = [];
    
    for i=1:N
        x = BBox(i,1);
        y = BBox(i,2);
        width = BBox(i,3);
        height = BBox(i,4);
        %boxArea = (BoundingBox(4)-BoundingBox(3))*(BoundingBox(2)-BoundingBox(1));
        if abs(width-height)<abs(width*0.1) && (width < 150)
            hypothesis = [hypothesis; [y y+height x x+width]];
        end
    end
    
    %get outlines of each object
    [B,L,N] = bwboundaries(just_red);
    %get stats
    stats =  regionprops(L,'BoundingBox');
    BBox = cat(1,stats.BoundingBox);
    
    for i=1:N
        x = BBox(i,1);
        y = BBox(i,2);
        width = BBox(i,3);
        height = BBox(i,4);
        %boxArea = (BoundingBox(4)-BoundingBox(3))*(BoundingBox(2)-BoundingBox(1));
        if abs(width-height)<abs(width*0.1) && (width < 150)
            hypothesis = [hypothesis; [y y+height x x+width]];
        end
    end
    
    %% Print
    
    figure();imshow(all_masks);title('Masks', 'FontSize', 15); % Display image
    
    signs_founded = hypothesis;

    % draw what we found
    
    hold on
    for i = 1 : size(signs_founded,1)
        pxd = [0 1 1 0]*(signs_founded(i,4)-signs_founded(i,3)) + signs_founded(i,3);
        pyd = [0 0 1 1]*(signs_founded(i,2)-signs_founded(i,1)) + signs_founded(i,1);
        patch(pxd, pyd, 'White', 'FaceColor', [0.8,1,0], 'FaceAlpha', 0.6);
    end
    
    %draw ground truth
    gt_index = find(strcmp({ground_truth.filename}, baseFileName)==1);
    gt_rectangles = ground_truth(gt_index).gt;
    for gti = 1 : size(gt_rectangles,1)
        px = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
        py = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
        patch(px, py,'White', 'FaceColor', [1,1,1], 'FaceAlpha', 0.5);
    end
    
    hold off

    %% COMPUTE STUFF FOR TOTAL SCORE
    n_signs_matched = 0;
    for gti = 1 : size(gt_rectangles,1)
        for i = 1 : size(signs_founded,1)
            % compute areas
            pxgt = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
            pygt = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
            pxsf = [0 1 1 0]*(signs_founded(i,4)-signs_founded(i,3)) + signs_founded(i,3);
            pysf = [0 0 1 1]*(signs_founded(i,2)-signs_founded(i,1)) + signs_founded(i,1);
            roigt = roipoly(gray_hsv,pxgt,pygt);
            roisf = roipoly(gray_hsv,pxsf,pysf);
            roiunion = roigt|roisf;
            roiinter = roigt&roisf;
            areai = sum(sum(roiinter));
            areau = sum(sum(roiunion));
            jscore = areai/areau;
            if jscore > 0.5
                n_signs_matched = n_signs_matched + 1;
            end
        end
    end
    
    total_signs_true_positive = total_signs_true_positive + n_signs_matched;
    total_signs_positive = total_signs_positive + size(signs_founded,1);
    total_signs_truth = total_signs_truth + size(gt_rectangles,1);
    
    drawnow; % Force display to update immediately.
end

total_precision = total_signs_true_positive/total_signs_positive;
total_recall = total_signs_true_positive/total_signs_truth;

fprintf(1, '\n\nPRECISION: %d  RECALL: %d\n', total_precision, total_recall);