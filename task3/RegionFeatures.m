% reset everything and close all open windows
clear all
close all
clc
directory = {'trafficlight' 'bottleneck' 'leftcurve' 'rightcurve' 'crossroad' 'scurve' 'snow' 'esclamationpoint'};
%% analyze every folder
for ww = 1 : length(directory)
    imagesFolder = directory{ww};
    if ~isdir(imagesFolder)
        errorMessage = sprintf('Error: The following folder does not exist:\n%s', imagesFolder);
        uiwait(warndlg(errorMessage));
        return;
    end
    
    
    % imagesFolder = 'trafficlight';
    %     if ~isdir(imagesFolder)
    %   errorMessage = sprintf('Error: The following folder does not exist:\n%s', imagesFolder);
    %   uiwait(warndlg(errorMessage));
    %   return;
    %     end
    
    % Get a list of all files in the folder with the desired file name pattern.
    filePattern = fullfile(imagesFolder, '*.png');
    theFiles = dir(filePattern);
 %% starting analyze images   
    for k = 1 : length(theFiles)
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(imagesFolder, baseFileName);
        fprintf(1, 'Now reading %s\n', fullFileName);
        signal = imread(fullFileName);
        mask = Preprocessing(signal);
        s=16000*0.03;
        mask1 = AreaConstraint(mask,s);
        mask2 = DefineCentralRegion(mask1);
        ss = 550;
        mask3 =AreaConstraint(mask2,ss);
        %figure();imshow(mask3);
        CC = bwconncomp(mask3);
        region = regionprops(CC,'Area','BoundingBox', 'Centroid', 'MajorAxisLength','MinorAxisLength','Orientation');
        
        a(ww).feature(k).Area = cat(1,region.Area);
        a(ww).feature(k).Bound = cat(1,region.BoundingBox);
        a(ww).feature(k).Centroid = cat(1,region.Centroid);
        a(ww).feature(k).Maxaxis = cat(1,region.MajorAxisLength);
        a(ww).feature(k).Minaxis = cat(1,region.MinorAxisLength);
        a(ww).feature(k).orient = cat(1,region.Orientation);
        data = a;
  
        e(ww).all_area = cat(1,a(ww).feature.Area);
        e(ww).all_centroid = cat(1,a(ww).feature.Centroid);
        e(ww).all_Maxaxis = cat(1,a(ww).feature.Maxaxis);
        e(ww).all_Minaxis = cat(1,a(ww).feature.Minaxis);
        the(ww).items(k) = CC.NumObjects;
        item(ww).object = cat(1,the(ww).items);
        media_oggetti(ww) = round(mean(item(ww).object)); 
       
    end
    lung = 0;
end;
%% plot area
for zz=1:length(directory)
    lung = length(e(zz).all_area);
    clear x;
    for tt = 1 : lung
        x(tt) = zz;
    end
    %fprintf(1,'siamo al numeroooooooo %d   ------------\n\n  ',zz);
    
    max_area = max(e(zz).all_area);
    min_area = min(e(zz).all_area);
    average_area = mean(e(zz).all_area);
    %hold on
    %     scatter(zz,average_area,15,'filled');
    %     scatter(x,e(zz).all_area,15,'filled');
end
%hold off
%% plot centroid

for zz=1:length(directory)
    
    %     hold on
    %     scatter(e(zz).all_centroid(:,1),e(zz).all_centroid(:,2),10,'filled');grid;
    %     legend('trafficlight', 'bottleneck' ,'leftcurve' ,'rightcurve', 'crossroad' ,'scurve', 'snow', 'esclamationpoint');
    average_x = mean(e(zz).all_centroid(:,1));
    average_y = mean(e(zz).all_centroid(:,2));
    max_centr_x = max(e(zz).all_centroid(:,1));
    max_centr_y = max(e(zz).all_centroid(:,2));
    min_centr_x = min(e(zz).all_centroid(:,1));
    min_centr_y = min(e(zz).all_centroid(:,2));
    %    scatter(average_x,average_y,30,'filled');grid
    
end
%hold off

%% plot maxaxis

for zz=1:length(directory)
    lung = length(e(zz).all_Maxaxis);
    clear x;
    for tt = 1 : lung
        x(tt) = zz;
    end
    %fprintf(1,'siamo al numeroooooooo %d   ------------\n\n  ',zz);
    
    max_maxAxis = max(e(zz).all_Maxaxis);
    min_maxAxis = min(e(zz).all_Maxaxis);
    average_maxAxis = mean(e(zz).all_Maxaxis);
    %     hold on
    %      scatter(zz,average_maxAxis,50,'filled');
    %      scatter(x,e(zz).all_Maxaxis,15,'filled');
end

%% plot minaxis

for zz=1:length(directory)
    lung = length(e(zz).all_Maxaxis);
    clear x;
    for tt = 1 : lung
        x(tt) = zz;
    end
    % fprintf(1,'siamo al numeroooooooo %d   ------------\n\n  ',zz);
    
    max_minAxis = max(e(zz).all_Minaxis);
    min_minAxis = min(e(zz).all_Minaxis);
    average_minAxis = mean(e(zz).all_Minaxis);
    %     hold on
    %      scatter(zz,average_minAxis,50,'filled');
    %      scatter(x,e(zz).all_Minaxis,15,'filled');
end

%% plot number of objects in each type of signal
for zz=1:length(directory)
%     hold on
%     scatter(zz,media_oggetti(zz),50,'filled');
end

%% plot 






