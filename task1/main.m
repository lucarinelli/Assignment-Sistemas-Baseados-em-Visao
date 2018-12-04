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

for k = 1 : 6 %length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imagesFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    
    original = imread(fullFileName);
    
    figure();
    subplot(2,2,1);
    imshow(original);title('Original', 'FontSize', 15);  % Display image.
    
    % draw ground truth
    hold on
    gt_index = find(strcmp({ground_truth.filename}, baseFileName)==1);
    gt_rectangles = ground_truth(gt_index).gt;
    for gti = 1 : size(gt_rectangles,1)
        px = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
        py = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
        %patch(px, py,'Green', 'FaceColor', [0,1,0], 'FaceAlpha', 0.3);
    end
    
    hold off
    
    % Contrast enhancement
    contrast = imadjust(original, stretchlim(original)); %%colored
    
    just_red = imsubtract(imsubtract(contrast(:,:,1),contrast(:,:,2)),contrast(:,:,3));
    just_green = imsubtract(imsubtract(contrast(:,:,2),contrast(:,:,1)),contrast(:,:,3));
    just_blue = imsubtract(imsubtract(contrast(:,:,3),contrast(:,:,2)),contrast(:,:,1));
    
    just_red = imadjust(just_red,stretchlim(just_red));
    just_green = imadjust(just_green,stretchlim(just_green));
    just_blue = imadjust(just_blue,stretchlim(just_blue));
    
    subplot(2,2,2);imshow(just_red);title('Red', 'FontSize', 15);
    subplot(2,2,3);imshow(just_green);title('Green', 'FontSize', 15);
    subplot(2,2,4);imshow(just_blue);title('Blue', 'FontSize', 15);
    
    
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