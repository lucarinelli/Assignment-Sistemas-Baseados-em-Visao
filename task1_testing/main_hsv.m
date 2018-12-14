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

for k = 1 : 2%length(theFiles)/2
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imagesFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    original = imread(fullFileName);
    
    figure();imshow(original);title('Original', 'FontSize', 15); % Display image.
    
    just_red = createMaskRed(original);
    just_blue = createMaskBlue(original);
    just_whitish = createMaskWhitish(original);
    
    %figure; imshow(just_whitish);title('W', 'FontSize', 10); % Display image.
    %figure; imshow(just_red);title('R', 'FontSize', 10); % Display image.
    %figure; imshow(just_blue);title('B', 'FontSize', 10); % Display image.
    
    all_masks = cat(3,255*uint8(just_red|just_whitish),just_whitish*255,255*uint8(just_blue|just_whitish));
    %figure();imshow(all_masks);title('Masks', 'FontSize', 15); % Display image
    
    Rmin = 10;
    Rmax = 40;
    [centersRed, radiiRed] = imfindcircles(just_red,[Rmin Rmax],'ObjectPolarity','dark');
    [centersBlue, radiiBlue] = imfindcircles(just_blue,[Rmin Rmax],'ObjectPolarity','dark');
    [centersWhitish, radiiWhitish] = imfindcircles(just_whitish,[Rmin Rmax],'ObjectPolarity','dark');
    [centersRedb, radiiRedb] = imfindcircles(just_red,[Rmin Rmax],'ObjectPolarity','bright');
    [centersBlueb, radiiBlueb] = imfindcircles(just_blue,[Rmin Rmax],'ObjectPolarity','dark');
    [centersWhitishb, radiiWhitishb] = imfindcircles(just_whitish,[Rmin Rmax],'ObjectPolarity','bright');
    
    %viscircles(centersRed, radiiRed,'LineStyle','--','Color','Red');
    %viscircles(centersBlue, radiiBlue,'LineStyle','--','Color','Blue');
    %viscircles(centersWhitish, radiiWhitish,'LineStyle','--','Color','Green');
    %viscircles(centersRedb, radiiRedb,'LineStyle','--','Color','Yellow');
    %viscircles(centersBlueb, radiiBlueb,'LineStyle','--','Color','Yellow');
    %viscircles(centersWhitishb, radiiWhitishb,'LineStyle','--','Color','Yellow');
    
    tollerance_centers = 10;
    tollerance_radii = 10;
    signs_founded = [];
    for i=1:size(centersRed)
        for j=1:size(centersRedb)
            if abs(centersRed(i,:)-centersRedb(j,:))<tollerance_centers
                for l=1:size(centersWhitish)
                    if abs(centersRed(i,:)-centersWhitish(l,:))<tollerance_centers
                        for m=1:size(centersWhitishb)
                            if abs(centersWhitish(l,:)-centersWhitishb(m,:))<tollerance_centers
                                if abs(radiiRed(i)-radiiRedb(j))<tollerance_radii && abs(radiiRed(i)-radiiWhitish(l))<tollerance_radii && abs(radiiWhitish(l)-radiiWhitishb(m))<tollerance_radii
                                    avg_center = (centersRed(i,:)+centersRedb(j,:)+centersWhitish(l,:)+centersWhitishb(m,:))/4;
                                    avg_radii = (radiiRed(i)+radiiRedb(j)+radiiWhitish(l)+radiiWhitishb(m))/4;
                                    signs_founded = [signs_founded; [avg_center(2)-avg_radii avg_center(2)+avg_radii avg_center(1)-avg_radii avg_center(1)+avg_radii]];
                                end     
                            end
                        end
                    end
                end
            end
        end
    end
    
    
    % NOT WORKING
%     for i=1:size(centersBlue)
%         for j=1:size(centersBlueb)
%             if abs(centersRed(i,:)-centersRedb(j,:))<tollerance_centers
%                 if abs(radiiRed(i)-radiiRedb(j))<tollerance_radii && abs(radiiRed(i)-radiiWhitish(l))<tollerance_radii && abs(radiiWhitish(l)-radiiWhitishb(m))<tollerance_radii
%                     avg_center = (centersBlue(i,:)+centersBlueb(j,:))/2;
%                     avg_radii = (radiiBlue(i)+radiiBlueb(j))/2;
%                     signs_founded = [signs_founded; [avg_center(2)-avg_radii avg_center(2)+avg_radii avg_center(1)-avg_radii avg_center(1)+avg_radii]];
%                 end
%             end
%         end
%     end

    % draw what we found
    hold on
    for i = 1 : size(signs_founded,1)
        px = [0 1 1 0]*(signs_founded(i,4)-signs_founded(i,3)) + signs_founded(i,3);
        py = [0 0 1 1]*(signs_founded(i,2)-signs_founded(i,1)) + signs_founded(i,1);
        patch(px, py,'White', 'FaceColor', [0.8,1,0], 'FaceAlpha', 0.6);
    end
    
    hold off
    
    % draw ground truth
    hold on
    gt_index = find(strcmp({ground_truth.filename}, baseFileName)==1);
    gt_rectangles = ground_truth(gt_index).gt;
    for gti = 1 : size(gt_rectangles,1)
        px = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
        py = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
        patch(px, py,'White', 'FaceColor', [1,1,1], 'FaceAlpha', 0.5);
    end
    
    hold off
    
end