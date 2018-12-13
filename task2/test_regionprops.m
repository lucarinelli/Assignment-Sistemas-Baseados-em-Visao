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
    
    figure();
    subplot(3,2,1);imshow(redMask);title('R');
    subplot(3,2,2);imshow(blueMask);title('Blue');
    subplot(3,2,3);imshow(yellowMask);title('Y');
    subplot(3,2,4);imshow(whitishMask);title('w');
    subplot(3,2,5);imshow(gray);title('gray');
    subplot(3,2,6);imshow(edges);title('edges');
    
    drawnow; % Force display to update immediately.
end