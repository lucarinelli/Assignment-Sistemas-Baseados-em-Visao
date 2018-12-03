% reset everything and close all open windows
clear all
close all
clc

%% load ground truth

load('ground_truth.mat')

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

for k = 1 : 2 %length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imagesFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    
    original = imread(fullFileName);
    
    figure();
    %subplot(2,1,1);
    imshow(original);title('Original', 'FontSize', 15);  % Display image.
    
    % Contrast enhancement
    con_img = imadjust(original, stretchlim(original)); %%colored
    con_img_gray = rgb2gray(con_img); %%gray
    con_img_gray = imadjust(con_img_gray, stretchlim(con_img_gray));

    % BINARIZED PIC
    bin_gray = im2bw(con_img_gray, 0.5);
    bin = imbinarize(con_img);
    figure()
    imshowpair(bin_gray,bin,'montage')
    title('Binarized (before opening) - gray vs color', 'FontSize', 15);

    bin_gray=bwareaopen(bin_gray, 300); % o q � o 300?
    bin=bwareaopen(bin, 300); 
    figure()
    imshowpair(bin_gray,bin,'montage')
    title('Binarized (after opening) - gray vs color', 'FontSize', 15);
    
    % draw ground truth
    hold on
    gt_index = find(strcmp({ground_truth.filename}, baseFileName)==1);
    gt_rectangles = ground_truth(gt_index).gt;
    for gti = 1 : size(gt_rectangles,1)
        px = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
        py = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
        patch(px, py,'Green', 'FaceColor', [0,1,0], 'FaceAlpha', 0.3);
    end
    
    hold off
    drawnow; % Force display to update immediately.
end