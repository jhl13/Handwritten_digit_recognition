function [feature,featureimg]=getfeature(image, is_float)
    if (nargin<2)
            is_float = 0;
    end
%% 找出数字区域
[ax,by] = find(image<=100);
image = image(min(ax):max(ax),min(by):max(by));
image = imresize(image, [100, 80]);
%% 计算格点
[N,M] = size(image);
row = floor(N/10);
col = floor(M/10);
area = row*col;
sign = zeros(10,10);
feature = zeros(100,1);
k=0;
if is_float == 0
    for i=1:1:10
        for j=1:1:10
            k=k+1;
            sign(i,j)=(length(find(image(1+(i-1)*row:i*row,1+(j-1)*col:j*col)<=100))/area>0.1);
            feature(k)=~sign(i,j);
        end
    end
    featureimg=~sign;
else
    for i=1:1:10
        for j=1:1:10
            k=k+1;
            sign(i,j)=(length(find(image(1+(i-1)*row:i*row,1+(j-1)*col:j*col)<=100))/area);
            feature(k)=1 - sign(i,j);
        end
    end
    featureimg=1 - sign;
    %featureimg = 1 - im2bw(sign,0.01);
end
end

