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

bad_recall_names = {};

for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imagesFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    original = imread(fullFileName);
    original_size = size(original);
    
    gray = rgb2gray(original);
    
    edges = edge(gray,'canny');
    just_red = createMaskRed(original);
    just_blue = createMaskBlue(original);
    just_whitish = createMaskWhitish(original);
    just_yellow = createMaskYellow(original);
    
    all_masks_no_magic = cat(3,255*uint8(just_red),255*just_whitish,255*uint8(just_blue));
    
    %% LET'S OBTAIN AS MANY COMPONENTS AS WE CAN, IN A REASONABLE WAY...
    
    old_whitish = just_whitish;
    just_whitish = just_whitish.*not(just_blue); % remove blue from white
    just_whitish = just_whitish.*not(just_red); % remove red from white
    just_red = just_red.*not(old_whitish); % if it is too white, then shouldn't be red
    just_blue = just_blue.*not(old_whitish); % same for blue
    just_blue = just_blue.*not(just_red); % if it is too red shouldn't be blue
    just_red = just_red.*not(just_blue); % and also the countrary is true
    just_blue = just_blue.*not(edges); %cut on edges to get more components... maybe...
    just_whitish = just_whitish.*not(edges); %cut on edges to get more components... maybe...
%     just_red = just_red.*not(edges);
    
    %% FILTERING
    
    hm_i={[1 0 0; 0 1 0; 0 0 1]; [0 1 0; 0 1 0; 0 1 0]; [0 0 1; 0 1 0; 1 0 0]; [1 0 0; 0 1 0; 0 1 0];
          [0 0 1; 0 1 0; 0 1 0]; [0 1 0; 0 1 0; 1 0 0]; [0 1 0; 0 1 0; 0 0 1]; [0 0 0; 1 1 1; 0 0 0];
          [0 0 0; 1 1 0; 0 0 1]; [0 0 1; 1 1 0; 0 0 0]; [0 0 0; 0 1 1; 1 0 0]; [1 0 0; 0 1 1; 0 0 0]};
    for asd=1:20
        fjust_red = bwhitmiss(just_red,hm_i{1});
        fjust_blue = bwhitmiss(just_blue,hm_i{1});
        fjust_whitish = bwhitmiss(just_whitish,hm_i{1});
        for lol=2:size(hm_i,1)
            fjust_red = fjust_red|bwhitmiss(just_red,hm_i{lol});
            fjust_blue = fjust_blue|bwhitmiss(just_blue,hm_i{lol});
            fjust_whitish = fjust_whitish|bwhitmiss(just_whitish,hm_i{lol});
        end
        just_red=fjust_red;
        just_blue=fjust_blue;
        just_whitish=fjust_whitish;
    end
    
    
    %figure; imshow(just_whitish);title('W', 'FontSize', 10); % Display image.
    %figure; imshow(just_red);title('R', 'FontSize', 10); % Display image.
    %figure; imshow(just_blue);title('B', 'FontSize', 10); % Display image.
    
    all_masks = cat(3,255*uint8(just_red),255*just_whitish,255*uint8(just_blue));
    all_masks_white = cat(3,255*uint8(just_red|just_whitish),255*just_whitish,255*uint8(just_blue|just_whitish));
    
    %% REGIONPROPS STUFF
    
    %get outlines of each BLUE object
    [B,L,N] = bwboundaries(just_blue,4);
    %get stats
    stats =  regionprops(L,'BoundingBox');%,'ConvexHull','Area');
    BBox = cat(1,stats.BoundingBox);

    hypothesisBlue = [];
    
    for i=1:N
        x = BBox(i,1);
        y = BBox(i,2);
        width = BBox(i,3);
        height = BBox(i,4);
        %boxArea = (BoundingBox(4)-BoundingBox(3))*(BoundingBox(2)-BoundingBox(1));
        if abs(width-height)<abs(mean([width height])*0.5) && width < 150 && width > 10 && height >10 && height < 150
            hypothesisBlue = [hypothesisBlue; [y y+height x x+width]];
        end
    end
    
    %get outlines of each RED object
    [B,L,N] = bwboundaries(just_red);
    %get stats
    stats =  regionprops(L,'BoundingBox');
    BBox = cat(1,stats.BoundingBox);
    
    hypothesisRed = [];
    
    for i=1:N
        x = BBox(i,1);
        y = BBox(i,2);
        width = BBox(i,3);
        height = BBox(i,4);
        %boxArea = (BoundingBox(4)-BoundingBox(3))*(BoundingBox(2)-BoundingBox(1));
        if abs(width-height)<abs(mean([width height])*0.5) && width < 150 && width > 10 && height >10 && height < 150
            hypothesisRed = [hypothesisRed; [y y+height x x+width]];
        end
    end
    
    %get outlines of each WHITE object
    [B,L,N] = bwboundaries(just_whitish,4);
    %get stats
    stats =  regionprops(L,'BoundingBox');
    BBox = cat(1,stats.BoundingBox);
    
    hypothesisWhite = [];
    
    for i=1:N
        x = BBox(i,1);
        y = BBox(i,2);
        width = BBox(i,3);
        height = BBox(i,4);
        %boxArea = (BoundingBox(4)-BoundingBox(3))*(BoundingBox(2)-BoundingBox(1));
        if abs(width-height)<abs(mean([width height])*0.5) && width < 150 && width > 10 && height >10 && height < 150
            center = [x+width/2 y+height/2];
            x = center(1) - width;
            y = center(2) - height;
            width = width * 4/3;
            height = height * 4/3;
            hypothesisWhite = [hypothesisWhite; [y y+height x x+width]];
        end
    end
    
    %get outlines of each YELLOW object
    [B,L,N] = bwboundaries(just_yellow,4);
    %get stats
    stats =  regionprops(L,'BoundingBox');
    BBox = cat(1,stats.BoundingBox);
    
    hypothesisYellow = [];
    
    for i=1:N
        x = BBox(i,1);
        y = BBox(i,2);
        width = BBox(i,3);
        height = BBox(i,4);
        %boxArea = (BoundingBox(4)-BoundingBox(3))*(BoundingBox(2)-BoundingBox(1));
        if abs(width-height)<abs(mean([width height])*0.5) && width < 150 && width > 10 && height >10 && height < 150
            center = [x+width/2 y+height/2];
            x = center(1) - width;
            y = center(2) - height;
            width = width * 3/2;
            height = height * 3/2;
            hypothesisYellow = [hypothesisYellow; [y y+height x x+width]];
        end
    end
%     
%     % and now let's look into the darker regions of deep space!
%     
%     %get outlines of each dark obj in BLUE
%     [B,L,N] = bwboundaries(not(just_blue));
%     %get stats
%     stats =  regionprops(L,'BoundingBox');%,'ConvexHull','Area');
%     BBox = cat(1,stats.BoundingBox);
% 
%     hypothesisBlueDark = [];
%     
%     for i=1:N
%         x = BBox(i,1);
%         y = BBox(i,2);
%         width = BBox(i,3);
%         height = BBox(i,4);
%         %boxArea = (BoundingBox(4)-BoundingBox(3))*(BoundingBox(2)-BoundingBox(1));
%         if abs(width-height)<abs(width*0.5) && width < 100 && width > 10 && height >10 && height < 100
%             center = [x+width/2 y+height/2];
%             x = center(1) - width;
%             y = center(2) - height;
%             width = width * 2;
%             height = height * 2;
%             hypothesisBlueDark = [hypothesisBlueDark; [y y+height x x+width]];
%         end
%     end
%     
%     %get outlines of each dark obj in RED
%     [B,L,N] = bwboundaries(not(just_red));
%     %get stats
%     stats =  regionprops(L,'BoundingBox');
%     BBox = cat(1,stats.BoundingBox);
%     
%     hypothesisRedDark = [];
%     
%     for i=1:N
%         x = BBox(i,1);
%         y = BBox(i,2);
%         width = BBox(i,3);
%         height = BBox(i,4);
%         %boxArea = (BoundingBox(4)-BoundingBox(3))*(BoundingBox(2)-BoundingBox(1));
%         if abs(width-height)<abs(width*0.5) && width < 100 && width > 10 && height >10 && height < 100
%             center = [x+width/2 y+height/2];
%             x = center(1) - width;
%             y = center(2) - height;
%             width = width * 2;
%             height = height * 2;
%             hypothesisRedDark = [hypothesisRedDark; [y y+height x x+width]];
%         end
%     end
%     
%     %get outlines of each dark in WHITE
%     [B,L,N] = bwboundaries(not(just_whitish));
%     %get stats
%     stats =  regionprops(L,'BoundingBox');
%     BBox = cat(1,stats.BoundingBox);
%     
%     hypothesisWhiteDark = [];
%     
%     for i=1:N
%         x = BBox(i,1);
%         y = BBox(i,2);
%         width = BBox(i,3);
%         height = BBox(i,4);
%         %boxArea = (BoundingBox(4)-BoundingBox(3))*(BoundingBox(2)-BoundingBox(1));
%         if abs(width-height)<abs(width*0.5) && width < 100 && width > 10 && height >10 && height < 100
%             center = [x+width/2 y+height/2];
%             x = center(1) - width;
%             y = center(2) - height;
%             width = width * 2;
%             height = height * 2;
%             hypothesisWhiteDark = [hypothesisWhiteDark; [y y+height x x+width]];
%         end
%     end
%     
%     %get outlines of each BLACK obj in all masks
%     [B,L,N] = bwboundaries(not(just_whitish|just_red|just_blue));
%     %get stats
%     stats =  regionprops(L,'BoundingBox');
%     BBox = cat(1,stats.BoundingBox);
%     
%     hypothesisBlack = [];
%     
%     for i=1:N
%         x = BBox(i,1);
%         y = BBox(i,2);
%         width = BBox(i,3);
%         height = BBox(i,4);
%         %boxArea = (BoundingBox(4)-BoundingBox(3))*(BoundingBox(2)-BoundingBox(1));
%         if abs(width-height)<abs(width*0.5) && width < 100 && width > 10 && height >10 && height < 100
%             center = [x+width/2 y+height/2];
%             x = center(1) - width;
%             y = center(2) - height;
%             width = width * 2;
%             height = height * 2;
%             hypothesisBlack = [hypothesisBlack; [y y+height x x+width]];
%         end
%     end
%     
%     
%     
     %% Filtering
     
     signs_founded = [];
    
    hypothesis = [hypothesisBlue; hypothesisRed; hypothesisWhite; hypothesisYellow]; %; hypothesisWhite; hypothesisBlack;hypothesisBlueDark; hypothesisRedDark; hypothesisWhiteDark];
    tried=0;
    passed = 0;
    for i = 1 : size(hypothesis,1)
        hyp=floor(hypothesis(i,:));
        tried = tried +1;
        window = original(max(1,hyp(1)):min(hyp(2),original_size(1)),max(1,hyp(3)):min(original_size(2),hyp(4)),:);
        if 1==1%task2func(window) == 1
            signs_founded = [signs_founded; hyp];
            %figure();imshow(window);
            passed = passed + 1;
        end
    end
    fprintf(1,'passed %d/%d\n',passed,tried);
    
    %% Print
    
    figure();imshow(all_masks_white);title('All masks', 'FontSize', 15); % Display image


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
    already_matched = [];
    for gti = 1 : size(gt_rectangles,1)
        for i = 1 : size(signs_founded,1)
            % compute areas
            pxgt = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
            pygt = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
            pxsf = [0 1 1 0]*(signs_founded(i,4)-signs_founded(i,3)) + signs_founded(i,3);
            pysf = [0 0 1 1]*(signs_founded(i,2)-signs_founded(i,1)) + signs_founded(i,1);
            roigt = roipoly(gray,pxgt,pygt);
            roisf = roipoly(gray,pxsf,pysf);
            roiunion = roigt|roisf;
            roiinter = roigt&roisf;
            areai = sum(sum(roiinter));
            areau = sum(sum(roiunion));
            jscore = areai/areau;
            if (jscore > 0.5) && numel(find(already_matched==gti))==0
                n_signs_matched = n_signs_matched + 1;
                already_matched = [already_matched; gti];
            end
        end
    end
    
    total_signs_true_positive = total_signs_true_positive + n_signs_matched;
    total_signs_positive = total_signs_positive + size(signs_founded,1);
    total_signs_truth = total_signs_truth + size(gt_rectangles,1);
    
    partial_precision = n_signs_matched/size(signs_founded,1);
    partial_recall = n_signs_matched/size(gt_rectangles,1);
    
    if(partial_recall<1)
        fprintf(1,'Bad recall! %d\n',partial_recall);
        bad_recall_names = [bad_recall_names; baseFileName];
    end
    
    drawnow; % Force display to update immediately.
end

total_precision = total_signs_true_positive/total_signs_positive;
total_recall = total_signs_true_positive/total_signs_truth;

fprintf(1, '\n\nPRECISION: %d  RECALL: %d\n', total_precision, total_recall);

bad_recall_names