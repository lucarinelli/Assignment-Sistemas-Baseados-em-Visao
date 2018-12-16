function [Convex_data] = Features_convex(Imm,ww,k,lunG)
%pre processing of images to extract the mask
%------------------------------------------------------


region = regionprops(Imm,'Area','BoundingBox', 'Centroid', 'MajorAxisLength','MinorAxisLength','Orientation');
        
        C(ww).feature(k).Area = cat(1,region.Area);
        C(ww).feature(k).Bound = cat(1,region.BoundingBox);
        C(ww).feature(k).Centroid = cat(1,region.Centroid);
        C(ww).feature(k).Maxaxis = cat(1,region.MajorAxisLength);
        C(ww).feature(k).Minaxis = cat(1,region.MinorAxisLength);
        C(ww).feature(k).orient = cat(1,region.Orientation);
        data = C;
  
        e(ww).all_area = cat(1,C(ww).feature.Area);
        e(ww).all_centroid = cat(1,C(ww).feature.Centroid);
        e(ww).all_Maxaxis = cat(1,C(ww).feature.Maxaxis);
        e(ww).all_Minaxis = cat(1,C(ww).feature.Minaxis);
        the(ww).items(k) = Imm.NumObjects;
        item(ww).object = cat(1,the(ww).items);
        media_oggetti(ww) = round(mean(item(ww).object)); 
       
    
    
%% plot area
% for zz=1:lunG
    
    lung = length(e(ww).all_area);
    clear x;
    for tt = 1 : lung
        x(tt) = ww;
     end
    
    %fprintf(1,'siamo al numeroooooooo %d   ------------\n\n  ',zz);
    
    max_area = max(e(ww).all_area);
    min_area = min(e(ww).all_area);
    average_area = mean(e(ww).all_area);
    %hold on
    %     scatter(zz,average_area,15,'filled');
    %     scatter(x,e(zz).all_area,15,'filled');
% end
%hold off
%% plot centroid

% for zz=1:lunG
    
    %     hold on
    %     scatter(e(zz).all_centroid(:,1),e(zz).all_centroid(:,2),10,'filled');grid;
    %     legend('trafficlight', 'bottleneck' ,'leftcurve' ,'rightcurve', 'crossroad' ,'scurve', 'snow', 'esclamationpoint');
    average_x = mean(e(ww).all_centroid(:,1));
    average_y = mean(e(ww).all_centroid(:,2));
    max_centr_x = max(e(ww).all_centroid(:,1));
    max_centr_y = max(e(ww).all_centroid(:,2));
    min_centr_x = min(e(ww).all_centroid(:,1));
    min_centr_y = min(e(ww).all_centroid(:,2));
    %    scatter(average_x,average_y,30,'filled');grid
    
% end
%hold off

%% plot maxaxis

% for zz=1:lunG
    lung = length(e(ww).all_Maxaxis);
    clear x;
    for tt = 1 : lung
        x(tt) = ww;
    end
    clear lung;
    %fprintf(1,'siamo al numeroooooooo %d   ------------\n\n  ',zz);
    
    max_maxAxis = max(e(ww).all_Maxaxis);
    min_maxAxis = min(e(ww).all_Maxaxis);
    average_maxAxis = mean(e(ww).all_Maxaxis);
    %     hold on
    %      scatter(zz,average_maxAxis,50,'filled');
    %      scatter(x,e(zz).all_Maxaxis,15,'filled');
% end

%% plot minaxis

% for zz=1:lunG
    lung = length(e(ww).all_Maxaxis);
    clear x;
    for tt = 1 : lung
        x(tt) = ww;
    end
    clear lung;
    % fprintf(1,'siamo al numeroooooooo %d   ------------\n\n  ',zz);
    
    max_minAxis = max(e(ww).all_Minaxis);
    min_minAxis = min(e(ww).all_Minaxis);
    average_minAxis = mean(e(ww).all_Minaxis);
    %     hold on
    %      scatter(zz,average_minAxis,50,'filled');
    %      scatter(x,e(zz).all_Minaxis,15,'filled');
% end

%% plot number of objects in each type of signal
% for zz=1:lunG
%     hold on
%     scatter(zz,media_oggetti(zz),50,'filled');
% end


Convex_data(ww).data = [average_x ;average_y; max_centr_x; max_centr_y; min_centr_x; min_centr_y; max_maxAxis; min_maxAxis;...
                average_maxAxis; max_minAxis; min_minAxis; average_minAxis;max_area ;min_area ;average_area ];





end