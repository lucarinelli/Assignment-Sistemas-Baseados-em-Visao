clc
clear all
close all

x=0;

%% reading original image
I = imread('124_1.png'); % change for arbitrary argument picture
format long;
var x;
var y;
I= im2double(I);
figure(1)
imshow(I)
xlabel('Original image');
hold on
 
%% binarization
% prompt = 'Binarization level: ';
% x = input(prompt);
% while(x>1||x<=0) 
%     disp('Expecting x in ]0 1] interval'); 
%     x = input(prompt); 
% end
% 
% bin=imbinarize(rgb2gray(I),'adaptive','ForegroundPolarity','dark','Sensitivity',x);
%figure()
%imshow(bin);
%xlabel(['After binarization (level ', int2str(x*100) ' * 10^-2)']);
%hold on

%% maximum intensity threshold for seed to grow to
prompt = 'Maximum intensity distance? (300 = practically covered): ';
ng = input(prompt)/1000
while(ng>1000||ng<=0) 
    disp('Expecting distance in ]0 1000] interval'); 
    ng = input(prompt)/100; 
end

%% displaying
disp('Considering picture size ')
disp(size(I));

J=rg_2(I, ng, 0); % mudar 0 para circleCenters

