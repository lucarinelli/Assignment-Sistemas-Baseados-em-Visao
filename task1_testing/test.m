% reset everything and close all open windows
clear all
close all
clc

%% load ground truth
load('ground_truth.mat')

% %% testing
% figure()
% A=imread('images/23_1.png');
% imshow(A);

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

for k = 1 : 2 %length(theFiles)-35
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imagesFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    
    original = imread(fullFileName);
    
    figure();
    %subplot(1,2,1);
    %imshow(original);title('Original', 'FontSize', 15);  % Display image.
    
    % Contrast enhancement
    contrast = imadjust(original, stretchlim(original)); %%colored
    
    con_img_gray = rgb2gray(contrast); %%gray
    con_img_gray = imadjust(con_img_gray, stretchlim(con_img_gray));
    
    % just the stuff that's red or blue
    just_red = imsubtract(imsubtract(contrast(:,:,1),contrast(:,:,2)),contrast(:,:,3));
    just_blue = imsubtract(imsubtract(contrast(:,:,3),contrast(:,:,2)),contrast(:,:,1));
    %just_white = 
    
    % to highlight also dark stuff
    % TODO Loose the binarization to take more stuff
    just_red = imbinarize(imadjust(just_red,stretchlim(just_red)));
    just_blue = imbinarize(imadjust(just_blue,stretchlim(just_blue)));
    
    % clean some noise
    just_red_2 = bwareaopen(just_red, 20);
    just_blue_2 = bwareaopen(just_blue, 20);
    
    % find edges on gray
    edge_gray = edge(con_img_gray,'Canny');
    
    % put together red, blue and edges on green
    red_n_blue = cat(3,uint8(255*just_red),edge_gray*255,uint8(255*just_blue));
    red_n_blue2 = cat(3,uint8(255*just_red_2),edge_gray*255,uint8(255*just_blue_2));
    
    Rmin = 6;
    Rmax = 100;
    [centersRed, radiiRed] = imfindcircles(just_red,[Rmin Rmax],'ObjectPolarity','bright');
    [centersBlue, radiiBlue] = imfindcircles(just_blue,[Rmin Rmax],'ObjectPolarity','bright');
    
    [centersRed2, radiiRed2] = imfindcircles(just_red_2,[Rmin Rmax],'ObjectPolarity','bright');
    [centersBlue2, radiiBlue2] = imfindcircles(just_blue_2,[Rmin Rmax],'ObjectPolarity','bright');
    
    
    % plot da things
    %subplot(1,2,2);
    %imshow(red_n_blue);title(strcat('Red&Blue edges in green ',fullFileName), 'FontSize', 15);
    figure(9)
    
    subplot(2,1,1);imshow(red_n_blue);title('red_n_blue', 'FontSize', 15);
    
    viscircles(centersRed, radiiRed,'LineStyle','--');
    viscircles(centersBlue, radiiBlue,'LineStyle','--');
    
    subplot(2,1,2);imshow(red_n_blue2);title('red_n_blue2', 'FontSize', 15);
 
    viscircles(centersRed2, radiiRed2,'LineStyle','--');
    viscircles(centersBlue2, radiiBlue2,'LineStyle','--');
 
    %% draw ground truth
    hold on
    gt_index = find(strcmp({ground_truth.filename}, baseFileName)==1);
    gt_rectangles = ground_truth(gt_index).gt;
    for gti = 1 : size(gt_rectangles,1)
        px = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
        py = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
        patch(px, py,'White', 'FaceColor', [1,1,1], 'FaceAlpha', 0.5);
    end
    
    hold off    
    drawnow; % Force display to update immediately.
end