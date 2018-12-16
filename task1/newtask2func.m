function [Verdict,newROI] = newtask2func(redMask,blueMask,whitishMask,yellowMask)
% "Nothing short of everything will really do."

window_size = size(redMask);

newROI = [];

all_masks_white = cat(3,255*(redMask|whitishMask|yellowMask),255*(whitishMask|yellowMask),255*uint8(blueMask|whitishMask));
    
%% CIRCLES
%dinamically adjust radii filter
Rmax = ceil(max(window_size)/2) + 2;
Rmin = ceil(Rmax/2);

% Find all the blue bright circles in the image
[centersBlueBright, radiiBlueBright] = imfindcircles(blueMask,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.90);
% Find all the blue dark circles in the image
%[centersBlueDark, radiiBlueDark] = imfindcircles(blueMask, [Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.90);

% Find all the blue bright circles in the image
[centersRedBright, radiiRedBright] = imfindcircles(redMask,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.90);
% Find all the blue dark circles in the image
[centersRedDark, radiiRedDark] = imfindcircles(redMask, [Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.90);

% Find all the blue bright circles in the image
%[centersWhiteBright, radiiWhiteBright] = imfindcircles(whitishMask,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.90);
% Find all the blue dark circles in the image
%[centersWhitishDark, radiiWhitishDark] = imfindcircles(redMask, [Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.90);

%% LINES

%              i1 gprio       i2 danger      i3 danger    14 gprio
ranges_theta = {-25:-0.25:-35; -25:-0.25:-35; 25:0.25:35; 25:0.25:35};% -80:-0.50:-89.5; 80:0.5:89.5};
ranges_rho = [-0.15 0.15; 0.2 0.6; 0.8 1; 0.3 0.6]*mean(window_size); %% <-------------------------------------------------QUESTO MEAN?

red_lines = [];

redl_sides = [0 0 0 0];
for i = 1 : size(ranges_theta,1)
    [H,T,R] = hough(redMask,'Theta',ranges_theta{i});

    P  = houghpeaks(H,1,'threshold',ceil(0.2*max(H(:))));

    lines_temp = houghlines(redMask,T,R,P,'FillGap',5,'MinLength',mean(2*window_size)/3);
    
    if size(lines_temp)~=0
        for j=1:size(lines_temp)
            if lines_temp(j).rho > ranges_rho(i,1) && lines_temp(j).rho < ranges_rho(i,2)
                %fprintf(1,'i %d rho %d\n',i,lines_temp(j).rho/mean(window_size));
                red_lines = [red_lines; lines_temp(j)'];
                redl_sides(i) = redl_sides(i) + 1;
            end
        end
    end
end


%% MASKS [SHOULD BE AS DYNAMIC AS POSSIBLE IDEALLY]
if size(centersRedBright,1)==1
    circ_mask1 = circularMask(centersRedBright,radiiRedBright,window_size);
    area_mask1 = pi*(radiiRedBright)^2;
elseif size(centersBlueBright,1)==1
    circ_mask1 = circularMask(centersBlueBright,radiiBlueBright,window_size);
    area_mask1 = pi*(radiiBlueBright)^2;
else
    circ_mask1 = circularMask(window_size/2,mean(window_size)/2,window_size);
    area_mask1 = pi*(mean(window_size)/2)^2;
end


% --------------------- SHOULD THEY BE DYNAMIC?
tria_mask3 = roipoly(redMask,[window_size(2)/2 window_size(2)/4 3*window_size(2)/4],[window_size(1)/4 3*window_size(1)/4 3*window_size(1)/4]);
tria_mask2 = roipoly(redMask,[window_size(2)/2 1 window_size(2)],[1 window_size(1) window_size(1)])-tria_mask3;

tria_mask5 = roipoly(redMask,[window_size(2)/4 3*window_size(2)/4 window_size(2)/2],[window_size(1)/4 window_size(1)/4 3*window_size(1)/4]);
tria_mask4 = roipoly(redMask,[1 window_size(2) window_size(2)/2],[1 1 window_size(1)])-tria_mask5;
% ----------------------

if size(centersRedDark,1)==1
    circ_mask7 = circularMask(centersRedDark,radiiRedDark,window_size);
    area_mask7 = pi*(radiiRedDark)^2;
else
    circ_mask7 = circularMask(window_size/2,2*mean(window_size)/3,window_size);
    area_mask7 = pi*(2*mean(window_size)/3)^2;
end

if size(centersRedBright,1)==1
    if size(centersRedDark,1)~=1
        circ_mask7 = circularMask(centersRedBright,2*(radiiRedBright)/3,window_size);
        area_mask7 = pi*(2*(radiiRedBright)/3)^2;
    end
    circ_mask6 = circularMask(centersRedBright,radiiRedBright,window_size) - circ_mask7;
    area_mask6 = pi*(radiiRedBright)^2-area_mask7;
else
    circ_mask6 = circularMask(window_size/2,mean(window_size)/2,window_size) - circ_mask7;
    area_mask6 = pi*(mean(window_size)/2)^2-area_mask7;
end

if size(centersRedBright,1)==1
    rect_mask8 = roipoly(redMask,[1 window_size(2) window_size(2) 1],[centersRedBright(2)-radiiRedBright/5 centersRedBright(2)-radiiRedBright/5 centersRedBright(2)+radiiRedBright/5 centersRedBright(2)+radiiRedBright/5]);
    area_mask8 = 4*radiiRedBright*radiiRedBright/5;
else
    rect_mask8 = roipoly(redMask,[1 window_size(2) window_size(2) 1],[5*window_size(1)/11 5*window_size(1)/11 7*window_size(1)/11 7*window_size(1)/11]);
    area_mask8 = sum(sum(rect_mask8));
end

top_part_mask = roipoly(redMask,[0 window_size(2) window_size(2) 0],[0 0 window_size(1)/2 window_size(1)/2]);
bottom_part_mask = not(top_part_mask);
quasicirc_mask9 = circ_mask1.*not(rect_mask8);
quasicirc_mask9t = quasicirc_mask9.*top_part_mask;
quasicirc_mask9b = quasicirc_mask9.*bottom_part_mask;
area_mask9 = area_mask1 - area_mask8;
area_mask9t = area_mask9/2;
area_mask9b = area_mask9/2;

diam_mask10 = roipoly(redMask,[window_size(2)/2 window_size(2)/4 window_size(2)/2 3*window_size(2)/4],[window_size(1)/4 window_size(1)/2 3*window_size(1)/4 window_size(1)/2]);
diam_mask11 = roipoly(redMask,[window_size(2)/2 1 window_size(2)/2 window_size(2)],[1 window_size(1)/2 window_size(1) window_size(1)/2]) - diam_mask10;

%% SCORING 

score_blue1 = sum(sum(circ_mask1.*blueMask))/area_mask1;
score_red1 = sum(sum(circ_mask1.*redMask))/area_mask1;
score_white1 = sum(sum(circ_mask1.*whitishMask))/area_mask1;

score_red2 = sum(sum(tria_mask2.*redMask))/sum(sum(tria_mask2));
score_red4 = sum(sum(tria_mask4.*redMask))/sum(sum(tria_mask4));

score_white2 = sum(sum(tria_mask2.*whitishMask))/sum(sum(tria_mask2));
score_white4 = sum(sum(tria_mask4.*whitishMask))/sum(sum(tria_mask4));

score_red3 = sum(sum(tria_mask3.*redMask))/sum(sum(tria_mask3));
score_red5 = sum(sum(tria_mask5.*redMask))/sum(sum(tria_mask5));

score_red6 = sum(sum(circ_mask6.*redMask))/area_mask6;
score_red7 = sum(sum(circ_mask7.*redMask))/area_mask7;

%score_white6 = sum(sum(circ_mask6.*whitishMask))/sum(sum(circ_mask6));
%score_white7 = sum(sum(circ_mask7.*whitishMask))/sum(sum(circ_mask7));
score_yellow7 = sum(sum(circ_mask7.*yellowMask))/area_mask7;

score_white8 = sum(sum(rect_mask8.*whitishMask))/area_mask8;
score_red8 = sum(sum(rect_mask8.*redMask))/area_mask8;
score_red9 = sum(sum(quasicirc_mask9.*redMask))/area_mask9;
score_red9t = sum(sum(quasicirc_mask9t.*redMask))/area_mask9t;
score_red9b = sum(sum(quasicirc_mask9b.*redMask))/area_mask9b;

score_white9t = sum(sum(quasicirc_mask9t.*whitishMask))/area_mask9t;
score_white9b = sum(sum(quasicirc_mask9b.*whitishMask))/area_mask9b;

score_yellow10 = sum(sum(diam_mask10.*yellowMask))/sum(sum(diam_mask10));
score_white11 = sum(sum(diam_mask11.*whitishMask))/sum(sum(diam_mask11));

%% DETECTION    
result='unknown';

%% DETECT HAVE PRIORITY
if score_yellow10 > 0.3 && score_white11 > 0.3
    result = 'hprio';
end

%% DETECT DANGER (Needs polygon/line recognition) [WEAK]
if (redl_sides(2) > 0 || redl_sides(3) > 0) && score_red2 > 0.4 && score_red3 < 0.15 && score_white2 < 0.65
    result = 'dangerbyoneline';
end

if (redl_sides(2) > 0 && redl_sides(3) > 0) && score_red2 > 0.4 && score_red3 < 0.15 && score_white2 < 0.65
    result = 'dangerby2line';
end

%% DETECT GIVE PRIORITY (Needs polygon/line recognition) [WEAK]
if (redl_sides(1) > 0 || redl_sides(4) > 0) && score_red4 > 0.4 && score_red5 < 0.15 && score_white4 < 0.65
    result = 'gpriobyoneline';
end

if (redl_sides(1) > 0 && redl_sides(4) > 0) && score_red4 > 0.4 && score_red5 < 0.15 && score_white4 < 0.65
    result = 'gprioby2line';
end

%% DETECT MANDATORY
if score_blue1 > 0.5 && score_white1 < 0.4 && score_red2 < 0.65 && score_red4 < 0.4
    if size(centersBlueBright,1)==1
        result='mandatorycircle';
        newROI = [centersBlueBright(2)-radiiBlueBright centersBlueBright(2)+radiiBlueBright centersBlueBright(1)-radiiBlueBright centersBlueBright(1)+radiiBlueBright];
%     elseif score_red2 < 0.2 && score_red4 < 0.3 && score_white1 > 0.1
%         result='mandatorycolor';
    end
end

%% DETECT PROHIBITORY
if score_red6 > 0.6 && score_red7 < 0.5
    if size(centersRedBright,1)==1 && size(centersRedDark,1)==1
        if score_red6 > 0.8
            result = 'prohibitory2circles';
            newROI = [centersRedBright(2)-radiiRedBright centersRedBright(2)+radiiRedBright centersRedBright(1)-radiiRedBright centersRedBright(1)+radiiRedBright];
        end
    elseif size(centersRedBright,1)==1 && score_red6 > 0.6 && score_red7 < 0.6 && score_blue1 < 0.1 && score_white1 > 0.35 && score_yellow7 < 0.2
        result = 'prohibitory1circle';
    end
end

%% DETECT STOP <----- not good enough, too many errors
if score_white9t < 0.4 && score_white9b < 0.4 && score_red9t > 0.5 && score_red9b > 0.5 && score_red8 < 0.7 && score_white8 > 0.1
    result = 'stop';
    if size(centersRedBright,1)==1
        newROI = [centersRedBright(2)-radiiRedBright centersRedBright(2)+radiiRedBright centersRedBright(1)-radiiRedBright centersRedBright(1)+radiiRedBright];
        result = 'stop--circle';
    end
end

%% DETECT FORBIDDEN
if score_white9t < 0.1 && score_white9b < 0.1 && score_red9t > 0.7 && score_red9b > 0.7 && score_red8 < 0.4
    result = 'forbidden';
    if size(centersRedBright,1)==1
        newROI = [centersRedBright(2)-radiiRedBright centersRedBright(2)+radiiRedBright centersRedBright(1)-radiiRedBright centersRedBright(1)+radiiRedBright];
        result = 'forbidden--circle';
    end
end

if(strcmp(result,'unknown')~=1)
    Verdict = 1;
    figure();imshow(all_masks_white);title(result);
%     subplot(2,2,1);imshow(redMask);title('R');
%     subplot(2,2,2);imshow(blueMask);title('Blue');
%     subplot(2,2,3);imshow(yellowMask);title('Y');
%     subplot(2,2,4);imshow(whitishMask);title('w');
else
    Verdict = 0;
end
    
end