function J = rg_2(I, reg_maxdist, centers)

if isempty(centers)==1
    J = 0;
    return
end

var i;

if(exist('reg_maxdist','var')==0), reg_maxdist=0.2; end
% figure(2) 
% imshow(I, [])
% xlabel('Please pick seeds pixel'); 
%[y,x]=centers; %guarda logo todos os pontos

centers(:,1)
w = length(centers(:,1))
y = [centers(:,1), zeros(w)];
x = [centers(:,2), zeros(w)];
%npoints=length(x(:,1));
npoints=length(x(:,1));
y=round(y); x=round(x);

for i=1:npoints
    
    J = zeros(size(I)); 
    Isizes = size(I); 
    
    reg_mean = I(x(i,1),y(i,1)); 
    reg_size = 1; 
    neg_free = 10000; neg_pos=0;
    neg_list = zeros(neg_free,3); 
    pixdist=0;
    viz=[-1 0; 1 0; 0 -1;0 1];

    while(pixdist<reg_maxdist&&reg_size<numel(I))

        for j=1:4

            xn = x(i,1) +viz(j,1); yn = y(i,1) +viz(j,2);
            ins=(xn>=1)&&(yn>=1)&&(xn<=Isizes(1))&&(yn<=Isizes(2));
            
            if(ins&&(J(xn,yn)==0)) 
                    neg_pos = neg_pos+1;
                    neg_list(neg_pos,:) = [xn yn I(xn,yn)]; J(xn,yn)=1;
            end
            
        end

        if(neg_pos+10>neg_free), neg_free=neg_free+10000; neg_list((neg_pos+1):neg_free,:)=0; end

        dist = abs(neg_list(1:neg_pos,3)-reg_mean);
        [pixdist, index] = min(dist);
        J(x(i,1),y(i,1))=2; reg_size=reg_size+1;

        reg_mean= (reg_mean*reg_size + neg_list(index,3))/(reg_size+1);

        x(i,1) = neg_list(index,1); y(i,1) = neg_list(index,2);

        neg_list(index,:)=neg_list(neg_pos,:); neg_pos=neg_pos-1;
    end

    J = J*1;
%     figure(2)
%     imshow(I);
%     xlabel(['Region grown image (proximity level ', int2str(reg_maxdist*1000), ' * 10^-3)']);
%     hold on
end

end
