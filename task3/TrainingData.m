function [data,data_convex] = TrainingData(directory)
%this function is used to analyze the data in the directory given by the 
%main program, it return all the features data for each type of images
%divided by folders


for ww = 1 : length(directory)
    imagesFolder = directory{ww};
    if ~isdir(imagesFolder)
        errorMessage = sprintf('Error: The following folder does not exist:\n%s', imagesFolder);
        uiwait(warndlg(errorMessage));
        return;
    end
    
    
    %% analyze every folder------------------------------------------------
    
    % Get a list of all files in the folder with the desired file name pattern.
    filePattern = fullfile(imagesFolder, '*.png');
    theFiles = dir(filePattern);
    %% starting analyze images---------------------------------------------
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
        Conv_image = bwconvhull(mask3);
        CC_conv = bwconncomp(Conv_image);
        region_convex = regionprops(CC_conv,'Area','BoundingBox', 'Centroid', 'MajorAxisLength','MinorAxisLength','Orientation');
        %Vett_features = Features_convex(CC_conv,ww,k,length(directory));
        %figure();imshow(Conv_image);
        %figure();imshow(mask3);
        CC = bwconncomp(mask3);
        region = regionprops(CC,'Area','BoundingBox', 'Centroid', 'MajorAxisLength','MinorAxisLength','Orientation');
        
        a(ww).feature(k).Area = cat(1,region.Area);
        a(ww).feature(k).Bound = cat(1,region.BoundingBox);
        a(ww).feature(k).Centroid = cat(1,region.Centroid);
        a(ww).feature(k).Maxaxis = cat(1,region.MajorAxisLength);
        a(ww).feature(k).Minaxis = cat(1,region.MinorAxisLength);
        a(ww).feature(k).orient = cat(1,region.Orientation);
        %data = a;
        
        e(ww).all_area = cat(1,a(ww).feature.Area);
        e(ww).all_centroid = cat(1,a(ww).feature.Centroid);
        e(ww).all_Maxaxis = cat(1,a(ww).feature.Maxaxis);
        e(ww).all_Minaxis = cat(1,a(ww).feature.Minaxis);
        the(ww).items(k) = CC.NumObjects;
        item(ww).object = cat(1,the(ww).items);
        media_oggetti(ww) = round(mean(item(ww).object));
        AAAA(ww).N_objects = media_oggetti(ww);
        
        
        C(ww).feature(k).Area = cat(1,region_convex.Area);
        C(ww).feature(k).Bound = cat(1,region_convex.BoundingBox);
        C(ww).feature(k).Centroid = cat(1,region_convex.Centroid);
        C(ww).feature(k).Maxaxis = cat(1,region_convex.MajorAxisLength);
        C(ww).feature(k).Minaxis = cat(1,region_convex.MinorAxisLength);
        C(ww).feature(k).orient = cat(1,region_convex.Orientation);
        data_C = C;
        
        O(ww).all_area = cat(1,C(ww).feature.Area);
        O(ww).all_centroid = cat(1,C(ww).feature.Centroid);
        O(ww).all_Maxaxis = cat(1,C(ww).feature.Maxaxis);
        O(ww).all_Minaxis = cat(1,C(ww).feature.Minaxis);
        
      
    end
    lung = 0;
end


%% plot area--------------------------------------------------------------
for zz=1:length(directory)
    lung = length(e(zz).all_area);
    clear x;
    for tt = 1 : lung
        x(tt) = zz;
    end
    
    max_area = max(e(zz).all_area);
    min_area = min(e(zz).all_area);
    average_area = mean(e(zz).all_area);
    
    AAAA(zz).max_area = max_area;
    AAAA(zz).min_area = min_area;
    AAAA(zz).averageArea = average_area;
    %hold on
    %     scatter(zz,average_area,15,'filled');
    %     scatter(x,e(zz).all_area,15,'filled');
    C_max_area = max(O(zz).all_area);
    C_min_area = min(O(zz).all_area);
    C_average_area = mean(O(zz).all_area);
    
    CCCC(zz).C_max_area = C_max_area;
    CCCC(zz).C_min_area = C_min_area;
    CCCC(zz).C_average_area = C_average_area;
    
    
end
%hold off
%% plot centroid----------------------------------------------------------

for zz=1:length(directory)
    
    %     hold on
    %     scatter(e(zz).all_centroid(:,1),e(zz).all_centroid(:,2),10,'filled');grid;
    %     fprintf(1,'siamo al numeroooooooo %d   ------------\n\n  ',zz);
    
    average_x = mean(e(zz).all_centroid(:,1));
    average_y = mean(e(zz).all_centroid(:,2));
    max_centr_x = max(e(zz).all_centroid(:,1));
    max_centr_y = max(e(zz).all_centroid(:,2));
    min_centr_x = min(e(zz).all_centroid(:,1));
    min_centr_y = min(e(zz).all_centroid(:,2));
    
    %    scatter(average_x,average_y,30,'filled');grid
    
    C_average_x = mean(O(zz).all_centroid(:,1));
    C_average_y = mean(O(zz).all_centroid(:,2));
    C_max_centr_x = max(O(zz).all_centroid(:,1));
    C_max_centr_y = max(O(zz).all_centroid(:,2));
    C_min_centr_x = min(O(zz).all_centroid(:,1));
    C_min_centr_y = min(O(zz).all_centroid(:,2));
    
    AAAA(zz).average_x = average_x;
    AAAA(zz).average_y = average_y;
    AAAA(zz).max_centr_x = max_centr_x;
    AAAA(zz).max_centr_y = max_centr_y;
    AAAA(zz).min_centr_x = min_centr_x;
    AAAA(zz).min_centr_y = min_centr_y;
    
    CCCC(zz).C_average_x = C_average_x;
    CCCC(zz).C_average_y = C_average_y;
    CCCC(zz).C_max_centr_x = C_max_centr_x;
    CCCC(zz).C_max_centr_y = C_max_centr_y;
    CCCC(zz).C_min_centr_x = C_min_centr_x;
    CCCC(zz).C_min_centr_y = C_min_centr_y;
 
end
%hold off

%% plot MaxAxis------------------------------------------------------------

for zz=1:length(directory)
    lung = length(e(zz).all_Maxaxis);
    clear x;
    for tt = 1 : lung
        x(tt) = zz;
    end
    %     fprintf(1,'siamo al numeroooooooo %d   ------------\n\n  ',zz);
    
    max_maxAxis = max(e(zz).all_Maxaxis);
    min_maxAxis = min(e(zz).all_Maxaxis);
    average_maxAxis = mean(e(zz).all_Maxaxis);
    
    AAAA(zz).max_maxAxis = max_maxAxis;
    AAAA(zz).min_maxAxis = min_maxAxis;
    AAAA(zz).average_maxAxis = average_maxAxis;
    
    
    
    %     hold on
    %      scatter(zz,average_maxAxis,50,'filled');
    %      scatter(x,e(zz).all_Maxaxis,15,'filled');
    C_max_maxAxis = max(O(zz).all_Maxaxis);
    C_min_maxAxis = min(O(zz).all_Maxaxis);
    C_average_maxAxis = mean(O(zz).all_Maxaxis);
    
    CCCC(zz).C_max_maxAxis = C_max_maxAxis;
    CCCC(zz).C_min_maxAxis = C_min_maxAxis;
    CCCC(zz).C_average_maxAxis = C_average_maxAxis;
    
end

%% plot MinAxis------------------------------------------------------------

for zz=1:length(directory)
    lung = length(e(zz).all_Maxaxis);
    clear x;
    for tt = 1 : lung
        x(tt) = zz;
    end
    %      fprintf(1,'siamo al numeroooooooo %d   ------------\n\n  ',zz);
    
    max_minAxis = max(e(zz).all_Minaxis);
    min_minAxis = min(e(zz).all_Minaxis);
    average_minAxis = mean(e(zz).all_Minaxis);
    
    AAAA(zz).max_minAxis = max_minAxis;
    AAAA(zz).min_minAxis = min_minAxis;
    AAAA(zz).average_minAxis = average_minAxis;
    
    
    %     hold on
    %      scatter(zz,average_minAxis,50,'filled');
    %      scatter(x,e(zz).all_Minaxis,15,'filled');
    C_max_minAxis = max(O(zz).all_Minaxis);
    C_min_minAxis = min(O(zz).all_Minaxis);
    C_average_minAxis = mean(O(zz).all_Minaxis);
    
    CCCC(zz).C_max_minAxis = C_max_minAxis;
    CCCC(zz).C_min_minAxis = C_min_minAxis;
    CCCC(zz).C_average_minAxis = C_average_minAxis;
       
end

%% data returned-----------------------------------------------------------

data = AAAA;
data_convex = CCCC;

end
