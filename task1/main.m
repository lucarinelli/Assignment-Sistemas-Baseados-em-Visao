% reset everything and close all open windows
clear all
close all
clc

%% silence, please.
warning('off','images:imfindcircles:warnForSmallRadius');

%% load ground truth
load('ground_truth.mat')

%% store our solution
total_output = {};

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
bad_precision_names = {};

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
    
    %figure();imshow(just_yellow*255);title('just yellow bef');
    
    all_masks_no_magic = cat(3,255*uint8(just_red),255*just_whitish,255*uint8(just_blue));
    
    %% LET'S OBTAIN AS MANY COMPONENTS AS WE CAN, IN A REASONABLE WAY...
    
    pre_whitish = just_whitish;
    old_red = just_red; % used later for filtering task2func
    old_blue = just_blue; % used later for filtering task2func
    
    just_whitish = just_whitish.*not(just_blue); % remove blue from white
    just_whitish = just_whitish.*not(just_red); % remove red from white
    old_whitish = just_whitish; % used later for filtering task2func
    just_red = just_red.*not(pre_whitish); % if it is too white, then shouldn't be red
    just_blue = just_blue.*not(pre_whitish); % same for blue
    just_blue = just_blue.*not(just_red); % if it is too red shouldn't be blue
    just_red = just_red.*not(just_blue); % and also the countrary is true
    just_blue = just_blue.*not(edges); %cut on edges to get more components... maybe...
    %just_red = just_red.*not(edges); %cut on edges to get more components... maybe...
    just_whitish = just_whitish.*not(edges); %cut on edges to get more components... maybe...
    
    %% FILTERING
    
    % just remove the very small noise without destroying anything that is
    % connected to something, just to improve a bit the performaces of
    % regionprops
    
    just_yellow = imopen(just_yellow,strel('diamond',7));
    %figure();imshow(just_yellow*255);title('just yellow');
    
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
    
    % put all the masks together just to make them look pretty when I show
    % them
    all_masks = cat(3,255*uint8(just_red),255*just_whitish,255*uint8(just_blue));
    all_masks_white = cat(3,255*uint8(just_red|just_whitish|just_yellow),255*(just_whitish|just_yellow),255*uint8(just_blue|just_whitish));
    all_masks_white_old = cat(3,255*uint8(old_red|old_whitish|just_yellow),255*(old_whitish|just_yellow),255*uint8(just_blue|old_whitish));
    
    %% REGIONPROPS STUFF
    
    %get outlines of each BLUE object
    [~,L,N] = bwboundaries(just_blue,4);
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
    [~,L,N] = bwboundaries(just_red,4);
    %get stats
    stats =  regionprops(L,'BoundingBox','Centroid');
    BBox = cat(1,stats.BoundingBox);
    Centroids = cat(1,stats.Centroid);
    
    hypothesisRed = [];
    hypothesisRedExt = [];
    
    for i=1:N
        center = [x+width/2 y+height/2];
        x = BBox(i,1);
        y = BBox(i,2);
        width = BBox(i,3);
        height = BBox(i,4);
        if abs(width-height)<abs(mean([width height])*0.5) && width < 150 && width > 12 && height >12 && height < 150
            hypothesisRed = [hypothesisRed; [y y+height x x+width]];
        end
        if abs(width-2*height)<width*0.4 && width < 150 && width > 10 && height > 5 && height < 70
            if abs(Centroids(i,1)-center(1))<width*0.1
                if Centroids(i,2)-center(2)>0
                    hypothesisRedExt = [hypothesisRedExt; [y-height*1.5 y+height x-2 x+width+2]];
                else
                    hypothesisRedExt = [hypothesisRedExt; [y y+height*2.5 x-2 x+width+2]];
                end
            end
        end
    end
    
    %get outlines of each WHITE object
    [~,L,N] = bwboundaries(just_whitish);
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
            width = width * 3/2;
            height = height * 3/2;
            hypothesisWhite = [hypothesisWhite; [center(2)-height/2 center(2)+height/2 center(1)-width/2 center(1)+width/2]];
        end
    end
    
    %get outlines of each YELLOW object
    [~,L,N] = bwboundaries(just_yellow);
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
        if abs(width-height)<abs(mean([width height])*0.5) && width < 150 && width > 5 && height > 5 && height < 150
            center = [x+width/2 y+height/2];
            width = width * 7/4;
            height = height * 7/4;
            hypothesisYellow = [hypothesisYellow; [center(2)-height/2 center(2)+height/2 center(1)-width/2 center(1)+width/2]];
        end
    end

    %% Filtering
    
    signs_founded = [];
    
    % order of hypothesis matters
    hypothesis = [hypothesisRedExt; hypothesisBlue; hypothesisRed; hypothesisYellow; hypothesisWhite]; %; hypothesisWhite; hypothesisBlack;hypothesisBlueDark; hypothesisRedDark; hypothesisWhiteDark];
    tried=0;
    passed = 0;
    for i = 1 : size(hypothesis,1)
        hyp=floor(hypothesis(i,:));
        tried = tried +1;
        windowRed = old_red(max(1,hyp(1)):min(hyp(2),original_size(1)),max(1,hyp(3)):min(original_size(2),hyp(4)),:);
        windowBlue = just_blue(max(1,hyp(1)):min(hyp(2),original_size(1)),max(1,hyp(3)):min(original_size(2),hyp(4)),:);
        windowWhitish = old_whitish(max(1,hyp(1)):min(hyp(2),original_size(1)),max(1,hyp(3)):min(original_size(2),hyp(4)),:);
        windowYellow = just_yellow(max(1,hyp(1)):min(hyp(2),original_size(1)),max(1,hyp(3)):min(original_size(2),hyp(4)),:);
        [Verdict, newROI] = newtask2func(windowRed,windowBlue,windowWhitish,windowYellow);
        if Verdict == 1
            if numel(newROI)~=0
                ROI_conf = [hyp(1) hyp(1) hyp(3) hyp(3)]+newROI;
            else
                ROI_conf = hyp;
            end
            
            found=0;
            for sfi=1:size(signs_founded,1)
                center_sfi = [mean(signs_founded(sfi,3:4)) mean(signs_founded(sfi,1:2))];
                center_roi = [mean(ROI_conf(3:4)) mean(ROI_conf(1:2))];
                if(norm(center_sfi-center_roi)<20)
                    found=1;
                end
            end
            
            if found==0
                signs_founded = [signs_founded; hyp];
                passed = passed + 1;
            end
        end
    end
    fprintf(1,'passed %d/%d\n',passed,tried);
    
    %% Print
    
    gt_index = find(strcmp({ground_truth.filename}, baseFileName)==1);
    gt_rectangles = ground_truth(gt_index).gt;
    
    figure();imshow(all_masks_white);title('First stage', 'FontSize', 15);
    
%     hold on
%     
%     for i = 1 : size(hypothesisRedExt,1)
%         pxd = [0 1 1 0]*(hypothesisRedExt(i,4)-hypothesisRedExt(i,3)) + hypothesisRedExt(i,3);
%         pyd = [0 0 1 1]*(hypothesisRedExt(i,2)-hypothesisRedExt(i,1)) + hypothesisRedExt(i,1);
%         patch(pxd, pyd, 'White', 'FaceColor', [0.5,0,1], 'FaceAlpha', 0.6);
%     end
%     
%     %draw ground truth
%     
%     for gti = 1 : size(gt_rectangles,1)
%         px = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
%         py = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
%         patch(px, py,'White', 'FaceColor', [1,1,1], 'FaceAlpha', 0.5);
%     end
%     
%     hold off
    
    figure();imshow(all_masks_white_old);title('Second stage', 'FontSize', 15);
    
    figure();imshow(original);title(k, 'Fontsize', 15);
    
    % draw what we found
    
    hold on
    for i = 1 : size(signs_founded,1)
        pxd = [0 1 1 0]*(signs_founded(i,4)-signs_founded(i,3)) + signs_founded(i,3);
        pyd = [0 0 1 1]*(signs_founded(i,2)-signs_founded(i,1)) + signs_founded(i,1);
        patch(pxd, pyd, 'White', 'FaceColor', [0.8,1,0], 'FaceAlpha', 0.6);
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
    
    if(partial_precision<1)
        fprintf(1,'Bad precision! %d\n',partial_precision);
        bad_precision_names = [bad_recall_names; baseFileName];
    end
    
    total_output = [ total_output; {baseFileName {signs_founded}}];
    
    drawnow; % Force display to update immediately.
end

total_precision = total_signs_true_positive/total_signs_positive;
total_recall = total_signs_true_positive/total_signs_truth;

fprintf(1, '\n\nPRECISION: %d  RECALL: %d\n', total_precision, total_recall);

total_output