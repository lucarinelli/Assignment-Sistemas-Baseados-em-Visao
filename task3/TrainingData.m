function [data] = TrainingData(directory)

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
    figure();imshow(mask3);
    CC = bwconncomp(mask3);
    region = regionprops(CC,'Area','BoundingBox', 'Centroid', 'MajorAxisLength','MinorAxisLength','Orientation');
    
     a(ww).feature(k).Area = cat(1,region.Area);
     a(ww).feature(k).Bound = cat(1,region.BoundingBox);
     a(ww).feature(k).Centroid = cat(1,region.Centroid);
     a(ww).feature(k).Maxaxis = cat(1,region.MajorAxisLength);
     a(ww).feature(k).Minaxis = cat(1,region.MinorAxisLength);
     a(ww).feature(k).orient = cat(1,region.Orientation);
     data = a;
%      for h=1:length(region.Area)
%     x(h)=h;
%      end
%         hold on
%      scatter(x,region.Area);
      
%      for re = 1:length([a(ww).feature(k).Area])
%      scatter([1:length([a(ww).feature(k).Area]),[a(ww).feature(k).Area]);
%      end
e(ww).all_area = cat(1,a(ww).feature.Area);
e(ww).all_centroid = cat(1,a(ww).feature.Centroid);
e(ww).all_Maxaxis = cat(1,a(ww).feature.Maxaxis);
%x_centr(ww) = cat(e(ww).all_centroid);
%y_centr(ww) = cat(e(ww).all_centroid(2));

% for h=1:length(all_area)
%     x(h)=h;
% end
% hold on 
% scatter(x,all_area);
% scatter(4,2800);
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
 max_area = max(e(zz).all_area);
 min_area = min(e(zz).all_area);
 average_area = mean(e(zz).all_area);
    hold on
%     scatter(zz,average_area,15,'filled');
%     scatter(x,e(zz).all_area,15,'filled');
end
hold off
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
%     scatter(average_x,average_y,30,'filled');grid 
      
end
%hold off

%% plot maxaxis


end
 



































% for ww = 1 : length(directory)
%     imagesFolder = directory{ww};
%     if ~isdir(imagesFolder)
%   errorMessage = sprintf('Error: The following folder does not exist:\n%s', imagesFolder);
%   uiwait(warndlg(errorMessage));
%   return;
%   end
%     
% 
% % imagesFolder = 'trafficlight';
% %     if ~isdir(imagesFolder)
% %   errorMessage = sprintf('Error: The following folder does not exist:\n%s', imagesFolder);
% %   uiwait(warndlg(errorMessage));
% %   return;
% %     end
% 
% % Get a list of all files in the folder with the desired file name pattern.
% filePattern = fullfile(imagesFolder, '*.png');
% theFiles = dir(filePattern);
% 
% for k = 1 : length(theFiles)
%     baseFileName = theFiles(k).name;
%     fullFileName = fullfile(imagesFolder, baseFileName);
%     fprintf(1, 'Now reading %s\n', fullFileName);
%     signal = imread(fullFileName);
%     mask = Preprocessing(signal);
%     s=16000*0.03;
%     mask1 = AreaConstraint(mask,s);
%     mask2 = DefineCentralRegion(mask1);
%     ss = 700;
%     mask3 =AreaConstraint(mask2,ss);
%     %figure();imshow(mask3);
%     CC = bwconncomp(mask3);
%     region = regionprops(CC,'Area','BoundingBox', 'Centroid', 'MajorAxisLength','MinorAxisLength','Orientation');
%     
%      a(ww).feature(k).Area = cat(1,region.Area);
%      a(ww).feature(k).Bound = cat(1,region.BoundingBox);
%      a(ww).feature(k).Centroid = cat(1,region.Centroid);
%      a(ww).feature(k).Maxaxis = cat(1,region.MajorAxisLength);
%      a(ww).feature(k).Minaxis = cat(1,region.MinorAxisLength);
%      a(ww).feature(k).orient = cat(1,region.Orientation);
%      data = a;
%      
% %     
% %      for re = 1:length([a(ww).feature(k).Area])
% %      scatter([1:length([a(ww).feature(k).Area]),[a(ww).feature(k).Area]);
% %      end
% end
% end
% end

