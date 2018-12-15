function [Verdict,newROI] = newtask2func(original)
% "Nothing short of everything will really do."

contrast = imadjust(original, stretchlim(original));
    
redMask = maskRed(contrast);
blueMask = maskBlue(contrast);
yellowMask = maskYellow(contrast);
whitishMask = maskWhitish(contrast);
gray = rgb2gray(contrast);
edges = edge(gray,'canny');

%% MAGIC ON MASKS

redMask = redMask.*not(whitishMask);
blueMask = blueMask.*not(whitishMask);
yellowMask = yellowMask.*not(whitishMask);
redMask = redMask.*not(blueMask);
blueMask = blueMask.*not(redMask);
whitishMask = whitishMask.*not(blueMask);
whitishMask = whitishMask.*not(redMask);
redMask = redMask.*not(yellowMask);
redMask = redMask.*not(edges);
blueMask = blueMask.*not(edges);
whitishMask = whitishMask.*not(edges);
yellowMask = yellowMask.*not(edges);

all_masks_white = cat(3,255*(redMask|whitishMask|yellowMask),255*(whitishMask|yellowMask),255*uint8(blueMask|whitishMask));
    
%% CIRCLES
%dinamically adjust radii filter
Rmax = ceil(max(size(gray))/2) + 2;
Rmin = ceil(Rmax/2);

% Find all the bright circles in the image
%[centersBright, radiiBright] = imfindcircles(gray,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.90);
% Find all the dark circles in the image
[centersDark, radiiDark] = imfindcircles(gray, [Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.96);

% Find all the blue bright circles in the image
%[centersBlueBright, radiiBlueBright] = imfindcircles(blueMask,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.90);
% Find all the blue dark circles in the image
%[centersBlueDark, radiiBlueDark] = imfindcircles(blueMask, [Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.90);

% Find all the blue bright circles in the image
[centersRedBright, radiiRedBright] = imfindcircles(redMask,[Rmin Rmax],'ObjectPolarity','bright','Sensitivity',0.90);
% Find all the blue dark circles in the image
[centersRedDark, radiiRedDark] = imfindcircles(redMask, [Rmin Rmax],'ObjectPolarity','dark','Sensitivity',0.90);

%% LINES

%              i1 gprio       i2 danger      i3 danger    14 gprio
ranges_theta = {-25:-0.25:-35; -25:-0.25:-35; 25:0.25:35; 25:0.25:35};% -80:-0.50:-89.5; 80:0.5:89.5};
ranges_rho = [-0.15 0.15; 0.2 0.6; 0.8 1; 0.3 0.6]*mean(size(gray));
lines = []; 

l_sides = [0 0 0 0];
for i = 1 : size(ranges_theta,1)
    [H,T,R] = hough(edges,'Theta',ranges_theta{i});

    P  = houghpeaks(H,1,'threshold',ceil(0.2*max(H(:))));

    lines_temp = houghlines(edges,T,R,P,'FillGap',5,'MinLength',mean(size(gray))/2);
    if size(lines_temp)~=0
        for j=1:size(lines_temp)
            if lines_temp(j).rho > ranges_rho(i,1) && lines_temp(j).rho < ranges_rho(i,2)
                fprintf(1,'i %d rho %d\n',i,lines_temp(j).rho/mean(size(gray)));
                lines = [lines; lines_temp(j)'];
                l_sides(i) = l_sides(i) + 1;
            end
        end
    end
end

red_lines = [];

redl_sides = [0 0 0 0];
for i = 1 : size(ranges_theta,1)
    [H,T,R] = hough(redMask,'Theta',ranges_theta{i});

    P  = houghpeaks(H,1,'threshold',ceil(0.2*max(H(:))));

    lines_temp = houghlines(redMask,T,R,P,'FillGap',5,'MinLength',mean(2*size(gray))/3);
    if size(lines_temp)~=0
        for j=1:size(lines_temp)
            if i==3
                fprintf(1,'i %d rho %d\n',i,lines_temp(j).rho/mean(size(gray)));
                red_lines = [red_lines; lines_temp(j)'];
                redl_sides(i) = redl_sides(i) + 1;
            end
        end
    end
end


%% MASKS [SHOULD BE AS DYNAMIC AS POSSIBLE IDEALLY]
if size(centersDark,1)==1 %MAYBE WE DON'T NEED THIS
    circ_mask1 = circularMask(centersDark,radiiDark+2,size(gray));       
else
    circ_mask1 = circularMask(size(gray)/2,mean(size(gray))/2,size(gray));
end

tria_mask3 = roipoly(gray,[size(gray,2)/2 size(gray,2)/4 3*size(gray,2)/4],[size(gray,1)/4 3*size(gray,1)/4 3*size(gray,1)/4]);
tria_mask2 = roipoly(gray,[size(gray,2)/2 1 size(gray,2)],[1 size(gray,1) size(gray,1)])-tria_mask3;

tria_mask5 = roipoly(gray,[size(gray,2)/4 3*size(gray,2)/4 size(gray,2)/2],[size(gray,1)/4 size(gray,1)/4 3*size(gray,1)/4]);
tria_mask4 = roipoly(gray,[1 size(gray,2) size(gray,2)/2],[1 1 size(gray,1)])-tria_mask5;

if size(centersRedDark,1)==1
    circ_mask7 = circularMask(centersRedDark,radiiRedDark+2,size(gray));       
else
    circ_mask7 = circularMask(size(gray)/2,2*mean(size(gray))/3,size(gray));
end

if size(centersRedBright,1)==1
    circ_mask6 = circularMask(centersRedBright,radiiRedBright+2,size(gray)) - circ_mask7;       
else
    circ_mask6 = circularMask(size(gray)/2,mean(size(gray))/2,size(gray)) - circ_mask7;
end

rect_mask8 = roipoly(gray,[5*size(gray,2)/12 5*size(gray,2)/12 7*size(gray,2)/12 7*size(gray,2)/12],[1 size(gray,1) 1 size(gray,1)]);
quasicirc_mask9 = circ_mask1 - rect_mask8;

diam_mask10 = roipoly(gray,[size(gray,2)/2 size(gray,2)/4 size(gray,2)/2 3*size(gray,2)/4],[size(gray,1)/4 size(gray,1)/2 3*size(gray,1)/4 size(gray,1)/2]);
diam_mask11 = roipoly(gray,[size(gray,2)/2 1 size(gray,2)/2 size(gray,2)],[1 size(gray,1)/2 size(gray,1) size(gray,1)/2]) - diam_mask10;

%% SCORING 

score_blue1 = sum(sum(circ_mask1.*blueMask))/sum(sum(circ_mask1));
score_white1 = sum(sum(circ_mask1.*whitishMask))/sum(sum(circ_mask1));

score_red2 = sum(sum(tria_mask2.*redMask))/sum(sum(tria_mask2));
score_red4 = sum(sum(tria_mask4.*redMask))/sum(sum(tria_mask4));

score_red3 = sum(sum(tria_mask3.*redMask))/sum(sum(tria_mask3));
score_red5 = sum(sum(tria_mask5.*redMask))/sum(sum(tria_mask5));

score_red6 = sum(sum(circ_mask6.*redMask))/sum(sum(circ_mask6));
score_red7 = sum(sum(circ_mask7.*redMask))/sum(sum(circ_mask7));

%score_white6 = sum(sum(circ_mask6.*whitishMask))/sum(sum(circ_mask6));
%score_white7 = sum(sum(circ_mask7.*whitishMask))/sum(sum(circ_mask7));
score_yellow7 = sum(sum(circ_mask7.*yellowMask))/sum(sum(circ_mask7));

score_white8 = sum(sum(rect_mask8.*whitishMask))/sum(sum(rect_mask8));
score_red9 = sum(sum(quasicirc_mask9.*redMask))/sum(sum(quasicirc_mask9));

score_yellow10 = sum(sum(diam_mask10.*yellowMask))/sum(sum(diam_mask10));
score_white11 = sum(sum(diam_mask11.*whitishMask))/sum(sum(diam_mask11));

%% DETECTION    
result='unknown';

%% DETECT STOP/FORBIDDEN(?) [REALLY WEAK]
if score_red9 > 0.55 && score_white8 > 0.19
    result = 'other';
end

%% DETECT HAVE PRIORITY
if score_yellow10 > 0.5 && score_white11 > 0.5
    result = 'other';
end

%% DETECT DANGER (Needs polygon/line recognition) [WEAK]
if (score_red2 > 0.5 && score_red3 < 0.5)% && score_red9 < 0.6) %&& (redl_sides(2)>0||l_sides(2)>0)||(redl_sides(3)>0||l_sides(3)>0))
    result = 'danger';
end

if (l_sides(2)>0 ||(redl_sides(2) > 0 && score_red9< 0.5))&&(l_sides(3) > 0 ||(redl_sides(3) > 0 && score_red9< 0.5))
    result = 'danger';
end

%% DETECT GIVE PRIORITY (Needs polygon/line recognition) [REALLY WEAK]
if score_red4 > 0.22 && score_red5 < 0.5 && score_red4 > score_red2 && strcmp(result,'danger')~=1
    result = 'other';
end

if (l_sides(1)>0 ||(redl_sides(1) > 0 && score_red9< 0.5))&&(l_sides(4) > 0 ||(redl_sides(4) > 0 && score_red9< 0.5))
    result = 'other';
end

%% DETECT MANDATORY
if score_blue1 > 0.5 && score_white1 < 0.4 && score_red2 < 0.65 && score_red4 < 0.4
    if size(centersDark,1)==1
        result='mandatory';
    elseif score_red2 < 0.2 && score_red4 < 0.3 && score_white1 > 0.1
        result='mandatory';
    end
end

%% DETECT PROHIBITORY (TO BE IMPROVED?)
if score_red6 > 0.5 && score_red7 < 0.5
    if size(centersRedBright,1)==1 && size(centersRedDark,1)==1
        result = 'prohibitory';
    elseif score_red6 > 0.6 && score_red7 < 0.6 && score_blue1 < 0.1 && score_white1 > 0.35 && score_yellow7 < 0.2
        result = 'prohibitory';
    end
end

figure();imshow(all_masks_white);
figure();
subplot(3,2,1);imshow(redMask);title('R');
subplot(3,2,2);imshow(blueMask);title('Blue');
subplot(3,2,3);imshow(yellowMask);title('Y');
subplot(3,2,4);imshow(whitishMask);title('w');
subplot(3,2,5);imshow(gray);title('gray');
subplot(3,2,6);imshow(edges);title('edges');

if(strcmp(result,'unknown')~=1)
    Verdict = 1;
else
    Verdict = 0;
end
    
end