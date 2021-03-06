%% test masks
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

for k = 1 : 1 %length(theFiles)
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
    [just_red, ored] = createMaskRed(original);%.*(not(thicken_edges));
    [just_blue, oblue] = createMaskBlue(original);%.*(not(thicken_edges));
    [just_whitish, owhitish] = createMaskWhitish(original);
    no_green = cat(3,original(:,:,1),zeros(original_size(1:2)),original(:,:,3));
    
    just_red = just_red.*not(just_whitish);
    just_blue = just_blue.*not(just_whitish);
    just_red = just_red.*not(just_blue);
    just_blue = just_blue.*not(just_red);
    just_whitish = just_whitish.*not(just_blue);
    just_whitish = just_whitish.*not(just_red);
    just_red = just_red.*not(edges);
    just_blue = just_blue.*not(edges);
    just_whitish = just_whitish.*not(edges);
    
    hm_i={[0 1 0; 0 1 0; 0 0 0]; [1 0 0; 0 1 0; 0 0 0]; [0 0 0; 1 1 0; 0 0 0]; [0 0 1; 0 1 0; 0 0 0]};
    for asd=1:20
        just_red = bwhitmiss(just_red,hm_i{1})| bwhitmiss(just_red,hm_i{2})| bwhitmiss(just_red,hm_i{3})|bwhitmiss(just_red,hm_i{4});
        just_blue = bwhitmiss(just_blue,hm_i{1})|bwhitmiss(just_blue,hm_i{2})|bwhitmiss(just_blue,hm_i{3})|bwhitmiss(just_blue,hm_i{4});
        just_whitish = bwhitmiss(just_whitish,hm_i{1})|bwhitmiss(just_whitish,hm_i{2})|bwhitmiss(just_whitish,hm_i{3})|bwhitmiss(just_whitish,hm_i{4});
    end
    
    ored_hsv=rgb2hsv(ored);
    oblue_hsv=rgb2hsv(oblue);
    
    
%     figure; imshow(just_whitish);title('W', 'FontSize', 10); % Display image.
%     figure; imshow(just_red);title('R', 'FontSize', 10); % Display image.
%     figure; imshow(just_blue);title('B', 'FontSize', 10); % Display image.
%     figure; imshow(owhitish);title('W', 'FontSize', 10); % Display image.
%     figure; imshow(ored_hsv(:,:,2));title('R', 'FontSize', 10); % Display image.
%     figure; imshow(oblue_hsv(:,:,2));title('B', 'FontSize', 10); % Display image.
%     figure; imshow(no_green);title('NG', 'FontSize', 10); % Display image.
%     figure; imshow(rgb2gray(no_green));title('GNG', 'FontSize', 10); % Display image.
    
    all_masks = cat(3,255*uint8(just_red),255*just_whitish,255*uint8(just_blue));
    
    %% Print
    figure();imshow(all_masks);title('Masks', 'FontSize', 15); % Display image
    
    %draw ground truth
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