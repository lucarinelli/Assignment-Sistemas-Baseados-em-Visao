% reset everything and close all open windows
clear all
close all
clc

%these associations are useful to define constraint to recognize the signal
trafficlight = 1;
bottleneck = 2;
leftcurve = 3;
rightcurve = 4;
crossroad = 5;
scurve = 6;
snow = 7;
exclamationpoint = 8;


%% load ground truth-------------------------------------------------------

load('ground_truth_3.mat')

%% training----------------------------------------------------------------

%giving a directory that defines some folders to the Training data function
%it returns  2 vectors that contains the data of the features of the
%mask and of the convex hull area of the mask
directories = {'trafficlight'; 'bottleneck'; 'leftcurve'; 'rightcurve'; 'crossroad'; 'scurve'; 'snow'; 'esclamationpoint'};
[datas, data_Conv] = TrainingData(directories);



%% load all the images-----------------------------------------------------
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
%we do it for every image in the folder
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imageFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    
    %% Preprocessing-------------------------------------------------------
    %in this section we try to mask the image, in order to have well
    %defined regions inside the mask
    original = imread(fullFileName);
    original1 = imresize(original,[400 400],'bilinear');
    bin_mask = Preprocessing(original);
    
    
    %% find regions (REGION PROMPS)----------------------------------------
    %we use regionprops function to define the central region of the signal
    %so we will be able to recognize it.
    smallestArea = 16000*0.03;
    bin_mask = AreaConstraint(bin_mask,smallestArea);
    
    %% regionprops define rectangle of interest----------------------------
    %it defines the central region of the mask, where the signal is
    %positioned
    bin_mask = DefineCentralRegion(bin_mask);
    
    %% again area constraint------------------------------------------------
    step1 = bin_mask;
    minArea = 700;
    bin_mask = AreaConstraint(bin_mask,minArea);
    
    
    %% starting classification---------------------------------------------
    
    CC2 = bwconncomp(bin_mask); %divide in region our mask
    Conv_image = bwconvhull(bin_mask); %transform in convex hull area our mask
    
    CC_convexhul = bwconncomp(Conv_image); %define region in convex hull
    %image (it's 1 region but it's useful later.
    confront_Hull = regionprops (CC_convexhul,'Area', 'Centroid', 'MajorAxisLength','MinorAxisLength','Eccentricity','Perimeter');
    confront = regionprops (CC2,'Area', 'Centroid', 'MajorAxisLength','MinorAxisLength','Eccentricity','Perimeter');
    
    %we check how many objects are in the mask
    switch CC2.NumObjects
        case 1
            
            if confront.Area > datas(crossroad).min_area
                if confront.Area > (datas(scurve).max_area + 200)
                    figure;imshow(original1);title('cross road');
                else
                    if confront.Area < (datas(crossroad).min_area - 300)
                        figure;imshow(original1);title('S curve');
                    else
                        if confront.Centroid(1,1) > datas(crossroad).max_centr_x
                            figure;imshow(original1);title('S curve');
                        else
                            if  confront_Hull.Eccentricity > data_Conv(crossroad).C_max_Eccentricity
                                figure;imshow(original1);title('S curve');
                            else
                                figure;imshow(original1);title('cross road');
                            end
                        end
                    end
                end
                
                
            else
                if confront.Eccentricity < datas(snow).max_Eccentricity+0.3
                    if confront_Hull.MajorAxisLength > data_Conv(exclamationpoint).C_max_minAxis + 10
                    figure;imshow(original1);title('snow');
                    end
                else
                    if confront.Centroid(1,1) < datas(rightcurve).max_centr_x +3
                        figure;imshow(original1);title('right curve');
                    else
                        if confront_Hull.Area < data_Conv(leftcurve).C_max_area
                            figure;imshow(original1);title('left curve');
                        else
                            figure;imshow(original1);title('s curve');
                        end
                    end
                end
            end
            
            
        case 2
            
            if confront_Hull.Centroid(1,2) < data_Conv(exclamationpoint).C_max_centr_y + 5
                 if confront_Hull.MinorAxisLength < data_Conv(exclamationpoint).C_max_minAxis + 5
                   figure;imshow(original1);title('esclamation point');
                 end
                 else
                     if confront_Hull.MinorAxisLength > data_Conv(bottleneck).C_min_minAxis - 5
                        figure;imshow(original1);title('bottleneck');
                     end
            end         
        case 3
            
            figure;imshow(original1);title('traffic lights');
        otherwise
            figure;imshow(original1);title('not found');
    end
    
    drawnow;
    
end


