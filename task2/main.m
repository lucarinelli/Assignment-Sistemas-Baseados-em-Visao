% reset everything and close all open windows
clear all
close all
clc

%% load ground truth

load('ground_truth_2.mat')

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
    
    original = imread(fullFileName);
    
    % Contrast enhancement, do we need this?
    contrast = imadjust(original, stretchlim(original)); %%colored
%     figure();imshow(contrast);
    
    redMask = maskRed(contrast);
    blueMask = maskBlue(contrast);
    yellowMask = maskYellow(contrast);
    whitishMask = maskWhitish(contrast);
    gray = rgb2gray(contrast);
    edges = edge(gray);
    
%     figure();
%     subplot(3,2,1);imshow(redMask);title('R');
%     subplot(3,2,2);imshow(blueMask);title('Blue');
%     subplot(3,2,3);imshow(yellowMask);title('Y');
%     subplot(3,2,4);imshow(whitishMask);title('w');
%     subplot(3,2,5);imshow(gray);title('gray');
%     subplot(3,2,6);imshow(edges);title('edges');
    
    
    %dinamically adjust radii filter
    Rmax = ceil(max(size(gray))/2) + 2;
    Rmin = ceil(Rmax/2);
    
    % Find all the bright circles in the image
    [centersBright, radiiBright] = imfindcircles(gray,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.90);
    % Find all the dark circles in the image
    [centersDark, radiiDark] = imfindcircles(gray, [Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.96);
    
    % Find all the blue bright circles in the image
    [centersBlueBright, radiiBlueBright] = imfindcircles(blueMask,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.90);
    % Find all the blue dark circles in the image
    [centersBlueDark, radiiBlueDark] = imfindcircles(blueMask, [Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.90);
    
    % Find all the blue bright circles in the image
    [centersRedBright, radiiRedBright] = imfindcircles(redMask,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.90);
    % Find all the blue dark circles in the image
    [centersRedDark, radiiRedDark] = imfindcircles(redMask, [Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.90);

    
    %% MASKS
    if size(centersDark,1)==1 %MAYBE WE DON'T NEED THIS
        circ_mask1 = circularMask(centersDark,radiiDark+2,size(gray));       
    else
        circ_mask1 = circularMask(size(gray)/2,mean(size(gray))/2,size(gray));
    end
    
    tria_mask3 = roipoly(gray,[size(gray,2)/2 size(gray,2)/4 3*size(gray,2)/4],[size(gray,1)/4 3*size(gray,1)/4 3*size(gray,1)/4]);
    tria_mask2 = roipoly(gray,[size(gray,2)/2 1 size(gray,2)],[1 size(gray,1) size(gray,1)])-tria_mask3;
    
    tria_mask5 = roipoly(gray,[size(gray,2)/4 3*size(gray,2)/4 size(gray,2)/2],[size(gray,1)/4 size(gray,1)/4 3*size(gray,1)/4]);
    tria_mask4 = roipoly(gray,[1 size(gray,2) size(gray,2)/2],[1 1 size(gray,1)])-tria_mask5;
    
    if size(centersRedDark,1)==1
        circ_mask7 = circularMask(centersRedDark,radiiRedDark+2,size(gray));       
    else
        circ_mask7 = circularMask(size(gray)/2,2*mean(size(gray))/3,size(gray));
    end
    
    if size(centersRedBright,1)==1
        circ_mask6 = circularMask(centersRedBright,radiiRedBright+2,size(gray)) - circ_mask7;       
    else
        circ_mask6 = circularMask(size(gray)/2,mean(size(gray))/2,size(gray)) - circ_mask7;
    end
    
    %% SCORING 
    
    score_blue1 = sum(sum(circ_mask1.*blueMask))/sum(sum(circ_mask1));
    score_white1 = sum(sum(circ_mask1.*whitishMask))/sum(sum(circ_mask1));
    
    score_red2 = sum(sum(tria_mask2.*redMask))/sum(sum(tria_mask2));
    score_red4 = sum(sum(tria_mask4.*redMask))/sum(sum(tria_mask4));
    
    score_red3 = sum(sum(tria_mask3.*redMask))/sum(sum(tria_mask3));
    score_red5 = sum(sum(tria_mask5.*redMask))/sum(sum(tria_mask5));
    
    score_red6 = sum(sum(circ_mask6.*redMask))/sum(sum(circ_mask6));
    score_red7 = sum(sum(circ_mask7.*redMask))/sum(sum(circ_mask7));
    
    %% DETECTION    
    result='dunno';
    
    %% DETECT MANDATORY
    if score_blue1 > 0.5 && score_white1 < 0.4 && score_red2 < 0.65 && score_red4 < 0.4
        if size(centersBlueBright,1)==1
            result='mandatory';
        elseif score_red2 < 0.2 && score_red4 < 0.3 && score_white1 > 0.1
            result='mandatory';
        end
    end
    
    %% DETECT PROHIBITORY (TO BE IMPROVED?)
    if score_red6 > 0.5 && score_red7 < 0.5
        if size(centersRedBright,1)==1 && size(centersRedDark,1)==1
            result = 'prohibitory';
        elseif score_red6 > 0.6 && score_red7 < 0.6 && score_blue1 < 0.1 && score_white1 > 0.35
            result = 'prohibitory';
        end
    end
    
    %% DETECT DANGER
    if score_red2 > 0.5 && score_red3 < 0.5
        result = 'danger';
%         if size(centersRedBright,1)==1 && size(centersRedDark,1)==1
%             result = 'prohibitory';
%         elseif score_red6 > 0.6 && score_red7 < 0.6 && score_blue1 < 0.1 && score_white1 > 0.35
%             result = 'prohibitory';
%         end
    end
    
    %% DETECT GIVE PRIORITY
    
    %% DETECT HAVE PRIORITY
    
    %% DETECT STOP/FORBIDDEN(?)
    
    %% PRINT STUFF
    
    gt_index = find(strcmp({ground_truth_2.filename}, baseFileName)==1);
    gt_name = ground_truth_2(gt_index).name;
    
    figure();imshow(original);
    % Plot bright circles in blue
    viscircles(centersBright, radiiBright,'Color','g');
    % Plot dark circles in dashed red boundaries
    viscircles(centersDark, radiiDark,'LineStyle','--','Color','g');
    % Plot dark circles in dashed red boundaries
    viscircles(centersBlueDark, radiiBlueDark,'LineStyle','--','Color','b');
    % Plot bright circles in blue
    viscircles(centersBlueBright, radiiBlueBright,'Color','b');
    % Plot dark circles in dashed red boundaries
    viscircles(centersRedDark, radiiRedDark,'LineStyle','--','Color','r');
    % Plot bright circles in blue
    viscircles(centersRedBright, radiiRedBright,'Color','r');
    
    if(strcmp(result, gt_name)==1)
        title(strcat('Correct! ',result,baseFileName));
    else
        title(strcat('\fontsize{16}\color{red}WRONG ',result,baseFileName))
        fprintf(1, 'r6 %d r7 %d b %d w %d\n', score_red6, score_red7, score_blue1, score_white1);
    end
    
    
    drawnow; % Force display to update immediately.
end