% reset everything and close all open windows
clear all
close all
clc

%% load ground truth

load('ground_truth_2.mat')

%% load all the images

% Specify the folder where the images are
imagesFolder = 'images';
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
    
    if size(centersDark,1)==1
        outer_rad = radiiDark+2;
        center = centersDark;

        [x,y] = meshgrid(1:size(gray,2),1:size(gray,1));

        distance = (x-center(1)).^2+(y-center(2)).^2;
        circ_mask = distance<outer_rad^2;
        
        score_blue = sum(sum(circ_mask.*blueMask))/sum(sum(circ_mask));
        
        fprintf(1, 'Score blue %d\n', score_blue);
        if score_blue > 0.5
            result='mandatory';
        else
            result='dunno';
        end
    else
        outer_rad = mean(size(gray));
        center = size(gray)/2;

        [x,y] = meshgrid(1:size(gray,2),1:size(gray,1));

        distance = (x-center(1)).^2+(y-center(2)).^2;
        circ_mask = distance<outer_rad^2;
        
        score_blue = sum(sum(circ_mask.*blueMask))/sum(sum(circ_mask));
        
        fprintf(1, 'Score blue %d\n', score_blue);
        if score_blue > 0.5
            result='mandatory';
        else
            result='dunno';
        end
    end
    
    gt_index = find(strcmp({ground_truth_2.filename}, baseFileName)==1);
    gt_name = ground_truth_2(gt_index).name;
    
    figure();imshow(original);
    % Plot bright circles in blue
    viscircles(centersBright, radiiBright,'Color','b');
    % Plot dark circles in dashed red boundaries
    viscircles(centersDark, radiiDark,'LineStyle','--');
    
    if(strcmp(result, gt_name)==1)
        title(strcat('Correct! ',result));
    else
        title(strcat('\fontsize{16}\color{red}WRONG ',result))
    end
    
    
    drawnow; % Force display to update immediately.
end