function bw=binarization(I)

 % Read the Image
figure(3),subplot(2,2,1),imshow(I); % display the  Original Image
subplot(2,2,2), imhist(I), hold on; % display the Histogram

n=imhist(I); % Compute the histogram
N=sum(n); % sum the values of all the histogram values
max=0; %initialize maximum to zero
P=zeros(256);

for i=1:256
    P(i)=n(i)/N; %Computing the probability of each intensity level
end
%%================================================================================================
for T=2:255      % step through all thresholds from 2 to 255
    w0=sum(P(1:T)); % Probability of class 1 (separated by threshold)
    w1=sum(P(T+1:256)); %probability of class2 (separated by threshold)
    u0=dot([0:T-1],P(1:T))/w0; % class mean u0
    u1=dot([T:255],P(T+1:256))/w1; % class mean u1
    sigma=w0*w1*((u1-u0)^2); % compute sigma i.e variance(between class)
    if sigma>max % compare sigma with maximum 
        max=sigma; % update the value of max i.e max=sigma
        threshold=T-1; % desired threshold corresponds to maximum variance of between class
    end
end
%%====================================================================================================
bw=im2bw(I,threshold/255); % Convert to Binary Image
figure(3),subplot(2,2,3), imshow(bw), xlabel('Binary Image'), subplot(2,2,4), imhist(bw),xlabel('Binary Image histogram'), hold on;
 % Display the Binary Image
end