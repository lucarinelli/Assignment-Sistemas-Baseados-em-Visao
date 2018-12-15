function [bin_mask] = Preprocessing(Image)
%pre processing of images to extract the mask
%------------------------------------------------------

resized = imresize(Image,[400 400],'bilinear');  %resize
resized2 = imsharpen(resized);
gray = rgb2gray(resized2);
gray_filt = medfilt2(gray);
tria_mask2 = roipoly(gray,[size(gray,2)/2 1 size(gray,2)],[1 size(gray,1) size(gray,1)]);   
[r c] = size(gray_filt);
mean = mean2(gray_filt(100:300,100:300)); 
%if the image is too dark, it increases contrast  
if mean <=40
    gray_filt = adapthisteq(gray_filt, 'ClipLimit' ,0.01,'NumTiles',[4 4]);     
end   
        
 step1 = gray_filt;
 
    for m=1:r
        for l=1:c
        if gray_filt(m,l) >=215 && gray_filt(m,l)<=255
            gray_filt(m,l) = 255;
        else
            gray_filt(m,l) = gray_filt(m,l);
            
        end
        end
    end
 
    resized_eq3 = adapthisteq(gray_filt, 'ClipLimit' ,0.01);
    bin3 = imbinarize(resized_eq3); %binarization
    bin3_compl = imcomplement(bin3);
    bin_mask = bin3_compl.*tria_mask2;
    
end
