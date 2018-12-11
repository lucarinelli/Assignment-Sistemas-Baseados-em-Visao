% reset everything and close all open windows
clear all
close all
clc

%% load ground truth

load('ground_truth.mat')

%% load all the images

% Specify the folder where the images are
imagesFolder = 'hard';
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
    
    figure();imshow(original);title('Original', 'FontSize', 15); % Display image.

    ImHSV = rgb2hsv(original);
     
    %figure();imshow(ImHSV);title('HSV', 'FontSize', 15); % Display image.
    
    HsvRed=ImHSV;
    for i = 1 : size(HsvRed,1)
        for j = 1 : size(HsvRed,2)
         if (10/360 < HsvRed(i,j,1))
             if(HsvRed(i,j,1) < 350/360) 
             HsvRed(i,j,2)= 0;
             HsvRed(i,j,3)= 0;
             end
         end
        end
    end
    S_red=HsvRed(:,:,2);
    S_red(S_red <0.7)=0;
    HsvRed(:,:,2)= S_red;
    V_red=HsvRed(:,:,3);
    V_red(V_red <1)= 0;
    HsvRed(:,:,3)= V_red;
    
    HsvB=ImHSV;
    for i = 1 : size(HsvB,1)
        for j = 1 : size(HsvB,2)
         if (230/360 < HsvB(i,j,1))
             if(HsvB(i,j,1) < 250/360) 
             HsvB(i,j,2)= 0;
             HsvB(i,j,3)= 0;
             end
         end
        end
    end
    
    S_b=HsvB(:,:,2);
    S_b(S_b <0.7)=0;
    HsvB(:,:,2)= S_b;
    V_b=HsvB(:,:,3);
    V_b(V_b <0.9)= 0;
    HsvB(:,:,3)= V_b;
    
    HsvY=ImHSV;
    for i = 1 : size(HsvY,1)
        for j = 1 : size(HsvY,2)
         if (50/360 < HsvY(i,j,1))
             if(HsvY(i,j,1) < 70/360) 
             HsvY(i,j,2)= 0;
             HsvY(i,j,3)= 0;
             end
         end
        end
    end
    S_y=HsvY(:,:,2);
    S_y(S_y <0.7)=0;
    HsvY(:,:,2)= S_y;
    V_y=HsvY(:,:,3);
    V_y(V_y <1)= 0;
    HsvY(:,:,3)= V_y;
    level=graythresh(HsvRed);
    HsvRed=im2bw(HsvRed,level);
    level=graythresh(HsvB);
    HsvB=im2bw(HsvB,level);
    level=graythresh(HsvY);
    HsvY=im2bw(HsvY,level);
    allmasks=(HsvRed | HsvB | HsvY);
    
    
    
    figure();imshow(allmasks);title('HSV R', 'FontSize', 15); % Display image.
    %figure();imshow(HsvBlue);title('HSV B', 'FontSize', 15); % Display image.
    %figure();imshow(HsvGreen);title('HSV G' , 'FontSize', 15); % Display image.
   
    % draw what we found
    %hold on
    %for i = 1 : size(signs_founded,1)
    %    px = [0 1 1 0]*(signs_founded(i,4)-signs_founded(i,3)) + signs_founded(i,3);
    %    py = [0 0 1 1]*(signs_founded(i,2)-signs_founded(i,1)) + signs_founded(i,1);
    %    patch(px, py,'White', 'FaceColor', [0.8,1,0], 'FaceAlpha', 0.6);
    %end
    
    %hold off
    
    % draw ground truth
   % hold on
   % gt_index = find(strcmp({ground_truth.filename}, baseFileName)==1);
   % gt_rectangles = ground_truth(gt_index).gt;
   % for gti = 1 : size(gt_rectangles,1)
   %     px = [0 1 1 0]*(gt_rectangles(gti,4)-gt_rectangles(gti,3)) + gt_rectangles(gti,3);
   %     py = [0 0 1 1]*(gt_rectangles(gti,2)-gt_rectangles(gti,1)) + gt_rectangles(gti,1);
   %     patch(px, py,'White', 'FaceColor', [1,1,1], 'FaceAlpha', 0.5);
   % end
    
   % hold off
    
end