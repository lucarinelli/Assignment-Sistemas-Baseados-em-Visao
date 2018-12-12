close all;
clear all;

A = ones(60,70);

tria_mask3 = roipoly(A,[size(A,2)/2 size(A,2)/4 3*size(A,2)/4],[size(A,1)/4 3*size(A,1)/4 3*size(A,1)/4]);
tria_mask2 = roipoly(A,[size(A,2)/2 1 size(A,2)],[1 size(A,1) size(A,1)])-tria_mask3;

tria_mask5 = roipoly(A,[size(A,2)/4 3*size(A,2)/4 size(A,2)/2],[size(A,1)/4 size(A,1)/4 3*size(A,1)/4]);
tria_mask4 = roipoly(A,[1 size(A,2) size(A,2)/2],[1 1 size(A,1)])-tria_mask5;

figure();
imshow(tria_mask2);
figure();
imshow(tria_mask3);
figure();
imshow(tria_mask4);
figure();
imshow(tria_mask5);