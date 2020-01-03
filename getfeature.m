function [feature,featureimg]=getfeature(image, is_float)
if (nargin<2)
    is_float = 0;
    %% 找出数字区域
    [ax,by] = find(image==0);
    image = image(min(ax):max(ax),min(by):max(by));
    image = imresize(image, [40, 40]);
    %% 计算格点
    [N,M] = size(image);
    row = floor(N/10);
    col = floor(M/10);
    area = row*col;
    sign = zeros(10,10);
    feature = zeros(100,1);
    k=0;
else
    %% 找出数字区域
    [ax,by] = find(image==0);
    image = image(min(ax):max(ax),min(by):max(by));
    image = imresize(image, [30, 30]);
    %% 计算格点
    [N,M] = size(image);
    row = floor(N/5);
    col = floor(M/5);
    area = row*col;
    sign = zeros(5,5);
    feature = zeros(25,1);
    k=0;
end

if is_float == 0
    for i=1:1:10
        for j=1:1:10
            k=k+1;
            sign(i,j)=(length(find(image(1+(i-1)*row:i*row,1+(j-1)*col:j*col)==0))/area>0.45);
            feature(k)=~sign(i,j);
        end
    end
    featureimg=~sign;
else
    for i=1:1:5
        for j=1:1:5
            k=k+1;
            sign(i,j)=(length(find(image(1+(i-1)*row:i*row,1+(j-1)*col:j*col)==0))/area);
            feature(k)=sign(i,j)-0.5;
        end
    end
    %featureimg=1 - sign;
    featureimg = 1 - im2bw(sign,0.01);
end
end

