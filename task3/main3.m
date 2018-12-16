% reset everything and close all open windows
clear all
close all
clc

%% load ground truth-------------------------------------------------------

load('ground_truth_3.mat')

%% training----------------------------------------------------------------

directories = {'trafficlight'; 'bottleneck'; 'leftcurve'; 'rightcurve'; 'crossroad'; 'scurve'; 'snow'; 'esclamationpoint'};
[datas, data_Conv] = TrainingData(directories);



%% load all the images---------------------------------------------------
% Specify the folder where the images are
imageFolder = 'danger';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(imageFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', imageFolder);
    uiwait(warndlg(errorMessage));
    return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(imageFolder, '*.png');
theFiles = dir(filePattern);

%% analyze images----------------------------------------------------------
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imageFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    
    %% Preprocessing-----------------------------------------------------------
    original = imread(fullFileName);
    bin_mask = Preprocessing(original);
    
    
    %% find regions (REGION PROMPS)--------------------------------------------
    smallestArea = 16000*0.03;
    bin_mask = AreaConstraint(bin_mask,smallestArea);
    
    %% regionprops define rectangle of interest--------------------------------
    bin_mask = DefineCentralRegion(bin_mask);
    
    %% again area contraint----------------------------------------------------
    step1 = bin_mask;
    minArea = 700;
    bin_mask = AreaConstraint(bin_mask,minArea);
    % figure();
    %     subplot(1,2,1);imshow(bin_mask);title('bin_mask');
    %     subplot(1,2,2);imshow(step1);title('step1');
    
    
    %% starting classification-------------------------------------------------
    % figure();imshow(bin_mask);
    CC1 = bwconncomp(bin_mask);
    classification = regionprops(CC1,'BoundingBox', 'centroid','area','Eccentricity');
    for qq=1: length(classification)
        thisBB = classification(qq).BoundingBox;
        %    rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
        %    'EdgeColor','r','LineWidth',2 );    
    end
    
    drawnow;
       
%       figure();
%       subplot(3,3,1);imshow(step1);title('step1', 'FontSize', 15);
%       subplot(3,3,2);imshow(bin_mask);title('bin_mask', 'FontSize', 15);
%     subplot(3,3,3);imshow(bin_mask);title('bin_mask', 'FontSize', 15);
%     subplot(3,3,4);imshow(dilate);title('dilate', 'FontSize', 15);
%     subplot(3,3,4);imshow(bin_mask);title('step1', 'FontSize', 15);
%     subplot(3,3,5);imshow(bin_mask);title('step1', 'FontSize', 15);
    

    
 
  