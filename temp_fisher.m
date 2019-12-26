%for test 
%using k-fold Cross-Validation
clc;
clear;
maindir = './100_digit';
k = 5;

train_proportion = 0.8;
test_proportion = 0.2;
subdir = dir(maindir);
total_images_num = 0;

floder_1_num = zeros(10, 1);
floder_1_feature = double([]);
floder_1_image_num = 0;

floder_2_num = zeros(10, 1);
floder_2_feature = double([]);
floder_2_image_num = 0;

floder_3_num = zeros(10, 1);
floder_3_feature = double([]);
floder_3_image_num = 0;

floder_4_num = zeros(10, 1);
floder_4_feature = double([]);
floder_4_image_num = 0;

floder_5_num = zeros(10, 1);
floder_5_feature = double([]);
floder_5_image_num = 0;

train_num = zeros(10, 1);
train_feature = double([]);
train_image_num = 0;

test_num = zeros(10, 1);
test_feature = double([]);
test_image_num = 0;

for i = 1 : length(subdir)
    if (isequal(subdir(i).name, '.') || ...
        isequal(subdir(i).name, '..') || ...
        ~subdir(i).isdir) % 跳过不是目录的子文件夹
        continue;
    end
    subdirpath = fullfile(maindir, subdir(i).name, '*.jpg');
    images = dir(subdirpath);
    i_images_num = length(images);
    
    i_floder_num = floor(length(images) * 0.2);
    floder_1_num(i-2) = i_floder_num;
    floder_2_num(i-2) = i_floder_num;
    floder_3_num(i-2) = i_floder_num;
    floder_4_num(i-2) = i_floder_num;
    floder_5_num(i-2) = length(images) - (i_floder_num * 4);
    
    for k_i = 1:k
        down_side = i_floder_num * (k_i - 1) + 1;
        if k_i ~=5
            up_side = i_floder_num * (k_i);
        else
            up_side = i_images_num;
        end
        for j = down_side:up_side
            imagepath = fullfile(maindir, subdir(i).name, images(j).name);
            imagedata = imread(imagepath);
            [feature,featureimg] = getfeature(reshape(imagedata, [28,28]), 1);
            if k_i == 1
                floder_1_image_num = floder_1_image_num + 1;
                floder_1_feature(floder_1_image_num, :) = [i - 3; feature];
            elseif k_i == 2
                floder_2_image_num = floder_2_image_num + 1;
                floder_2_feature(floder_2_image_num, :) = [i - 3; feature];
            elseif k_i == 3
                floder_3_image_num = floder_3_image_num + 1;
                floder_3_feature(floder_3_image_num, :) = [i - 3; feature];
            elseif k_i == 4
                floder_4_image_num = floder_4_image_num + 1;
                floder_4_feature(floder_4_image_num, :) = [i - 3; feature];
            elseif k_i == 5
                floder_5_image_num = floder_5_image_num + 1;
                floder_5_feature(floder_5_image_num, :) = [i - 3; feature];
            end
        end
    end
end

template_feature = floder_5_feature;
template_feature_num = floder_5_num;
% testfeature = (100, 1)
% template_feature = (num, 101) 第一个为类别，后100个为特征
% template_num = (10, 1)
P_i = zeros(10, 100); % wi类的 j个特征的均值
P_other = zeros(10, 100); % wi类的 j个特征的均值
s_i_cov = []; %各类别协方差 (10, 100, 100)
s_other_cov = []; %其余九类别协方差 (10, 100, 100)
Pw = zeros(10, 1); % 先验概率
[total_num, ~] = size(template_feature);
Pw = template_feature_num / total_num;

image = imread("./100_digit/9/9_115.jpg");
[test_feature,test_featureimg] = getfeature(reshape(image, [28,28]), 1);

for i=1:10
    for j=2:101
        class_index = template_feature(:, 1) == i-1;
        numof1=sum(template_feature(class_index,j)==1);
        P_i(i,j)=(numof1+1)/(template_feature_num(i)+2);
        
        class_index = template_feature(:, 1) ~= i-1;
        numof1=sum(template_feature(class_index,j)==1);
        P_other(i,j)=(numof1+1)/((sum(template_feature_num) - template_feature_num(i)) + 2);
    end
    i_feature = template_feature(template_feature(:, 1) == i-1,:);
    s_i_cov(i).dat = cov(i_feature(:,2:101)); % 求各类别的协方差矩阵
    i_other_feature = template_feature(template_feature(:, 1) ~= i-1,:);
    s_other_cov(i).dat = cov(i_other_feature(:,2:101)); % 其余九类别的协方差矩阵
end

confidence = zeros(10,1);
for i=1:10
    s_w = (template_feature_num(i) * s_i_cov(i).dat + ...
        (sum(template_feature_num) - template_feature_num(i)) * s_other_cov(i).dat) / sum(template_feature_num);
    w = pinv(s_w) * (P_i(i,2:101) - P_other(i,2:101))';
    w0 = -(1/2) * (P_i(i,2:101) + P_other(i,2:101)) * pinv(s_w) * (P_i(i,2:101) - P_other(i,2:101))' - log((1 - Pw(i))/Pw(i));
    g_test = w' * test_feature + w0;
    confidence(i) = g_test;
end

[v,result]=max(confidence);
result = result - 1
