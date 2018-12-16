% reset everything and close all open windows
clear all
close all
clc

trafficlight = 1;
bottleneck = 2;
leftcurve = 3;
rightcurve = 4;
crossroad = 5;
scurve = 6;
snow = 7;
esclamationpoint = 8;


%% load ground truth-------------------------------------------------------

load('ground_truth_3.mat')

%% training----------------------------------------------------------------

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
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(imageFolder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    
    %% Preprocessing-------------------------------------------------------
    original = imread(fullFileName);
    original1 = imresize(original,[400 400],'bilinear');
    bin_mask = Preprocessing(original);
    
    
    %% find regions (REGION PROMPS)----------------------------------------
    smallestArea = 16000*0.03;
    bin_mask = AreaConstraint(bin_mask,smallestArea);
    
    %% regionprops define rectangle of interest----------------------------
    bin_mask = DefineCentralRegion(bin_mask);
    
    %% again area constraint------------------------------------------------
    step1 = bin_mask;
    minArea = 700;
    bin_mask = AreaConstraint(bin_mask,minArea);
    
    
    %% starting classification---------------------------------------------
    CC2 = bwconncomp(bin_mask);
    Conv_image = bwconvhull(bin_mask);
    %
    %      figure();
    %         subplot(1,2,1);imshow(bin_mask);title('bin_mask');
    %          subplot(1,2,2);imshow(Conv_image);title('step1');
    
    CC_convexhul = bwconncomp(Conv_image);
    confront_Hull = regionprops (CC_convexhul,'Area', 'Centroid', 'MajorAxisLength','MinorAxisLength','Eccentricity','Perimeter');
    confront = regionprops (CC2,'Area', 'Centroid', 'MajorAxisLength','MinorAxisLength','Eccentricity','Perimeter');
    
    switch CC2.NumObjects
        case 1
            
            if confront.Area > datas(crossroad).min_area 
                if confront.Area > (datas(scurve).max_area + 300)
                    figure;imshow(original1);title('cross road');
                else
                    if confront.Area < (datas(crossroad).min_area - 400)
                        figure;imshow(original1);title('S curve');
                    else 
%                         if confront.Eccentricity > data_Conv(crossroad).C_max_centr_x && confront.Eccentricity < data_Conv(crossroad).C_max_centr_x
%                         C_max_centr_x
                        if confront_Hull.Eccentricity > data_Conv(crossroad).C_min_Eccentricity +0.01 && confront_Hull.Eccentricity < data_Conv(crossroad).C_max_Eccentricity
                            figure;imshow(original1);title('cross road');
                        else
                            if confront.Centroid(1,1) > datas(crossroad).max_centr_x
                            figure;imshow(original1);title('S curve');
                            else
                              figure;imshow(original1);title('cross road');  
                            end
                        end
                    end
                end

            else
                    
                if confront_Hull.Area > (data_Conv(snow).C_min_area - 300)
                    figure;imshow(original1);title('snow');
                else 
                    if confront_Hull.Centroid(1,1) < data_Conv(rightcurve).C_max_centr_x +5
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
                
%                 if confront.Centroid(1,1) > (datas(rightcurve).max_centr_x+10)
%                     if confront.Area > (datas(leftcurve).max_area + 500)
% %                         figure;imshow(original1);title(' S Curve');
%                     else
%                        % figure;imshow(original1);title(' left curve');
%                     end
%                 else
%                    % figure;imshow(original1);title(' right curve');
%                 end
%             end
            
            
            
            
        case 2
            if confront_Hull.MinorAxisLength > (data_Conv(bottleneck).C_min_minAxis-5) && confront_Hull.MinorAxisLength < (data_Conv(bottleneck).C_max_minAxis+5)
               % figure;imshow(original1);title('bottleneck');
            end
            if confront_Hull.MinorAxisLength > (data_Conv(esclamationpoint).C_min_minAxis-5) && confront_Hull.MinorAxisLength < (data_Conv(esclamationpoint).C_max_minAxis+5)
             %   figure;imshow(original1);title('esclamation point');
            end
            
        case 3
            %figure;imshow(original1);title('traffic lights');
        otherwise
            disp('other value')
    end
    
    
    drawnow;
    
    %       figure();
    %       subplot(3,3,1);imshow(step1);title('step1', 'FontSize', 15);
    %       subplot(3,3,2);imshow(bin_mask);title('bin_mask', 'FontSize', 15);
    %     subplot(3,3,3);imshow(bin_mask);title('bin_mask', 'FontSize', 15);
    %     subplot(3,3,4);imshow(dilate);title('dilate', 'FontSize', 15);
    %     subplot(3,3,4);imshow(bin_mask);title('step1', 'FontSize', 15);
    %     subplot(3,3,5);imshow(bin_mask);title('step1', 'FontSize', 15);
    
end


