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
            imagedata = imresize(imagedata, [28,28]);
            thresh=graythresh(imagedata);%确定二值化阈值
            imagedata=im2bw(imagedata,thresh);%对图像二值化
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

for k_i = 1:k
    if k_i == 1
        accuracy_1 = 0;
        correct_num = 0;
        train_num = floder_2_num + floder_3_num + floder_4_num + floder_5_num;
        train_feature = [floder_2_feature; floder_3_feature; floder_4_feature; floder_5_feature];
        test_image_num = floder_1_image_num;
        accuracy_1 = calculate_acc(floder_1_feature, floder_1_image_num, train_feature, train_num);
    end
    if k_i == 2
        accuracy_2 = 0;
        correct_num = 0;
        train_num = floder_1_num + floder_3_num + floder_4_num + floder_5_num;
        train_feature = [floder_1_feature; floder_3_feature; floder_4_feature; floder_5_feature];
        test_image_num = floder_2_image_num;
        accuracy_2 = calculate_acc(floder_2_feature, floder_2_image_num, train_feature, train_num);
    end
    if k_i == 3
        accuracy_3 = 0;
        correct_num = 0;
        train_num = floder_1_num + floder_2_num + floder_4_num + floder_5_num;
        train_feature = [floder_1_feature; floder_2_feature; floder_4_feature; floder_5_feature];
        test_image_num = floder_3_image_num;
        accuracy_3 = calculate_acc(floder_3_feature, floder_3_image_num, train_feature, train_num);
    end
    if k_i == 4
        accuracy_4 = 0;
        correct_num = 0;
        train_num = floder_1_num + floder_2_num + floder_3_num + floder_5_num;
        train_feature = [floder_1_feature; floder_2_feature; floder_3_feature; floder_5_feature];
        test_image_num = floder_4_image_num;
        accuracy_4 = calculate_acc(floder_4_feature, floder_4_image_num, train_feature, train_num);
    end
    if k_i == 5
        accuracy_5 = 0;
        correct_num = 0;
        train_num = floder_1_num + floder_2_num + floder_3_num + floder_4_num;
        train_feature = [floder_1_feature; floder_2_feature; floder_3_feature; floder_4_feature];
        test_image_num = floder_5_image_num;
        accuracy_5 = calculate_acc(floder_5_feature, floder_5_image_num, train_feature, train_num);
    end
end

accuracy = (accuracy_1 + accuracy_2 + accuracy_3 + accuracy_4 + accuracy_5) / 5;
acc_bar = [accuracy_1, accuracy_2, accuracy_3, accuracy_4, accuracy_5, accuracy];
name = categorical({'floder1', 'floder2', 'floder3', 'floder4', 'floder5', 'floderaverage'});
b = bar(name, acc_bar);
b.FaceColor = 'flat';
b.CData(6,:) = [1 0 0];
ylabel("accuracy of each experiment")
xlabel("test floder")
title("5 floder cross validation")

for text_i = 1:6
    text(text_i - 0.3, acc_bar(text_i) + 0.05, num2str(acc_bar(text_i)))
end

function [accuracy]=calculate_acc(floder_test_feature, floder_test_image_num, train_feature, train_num)
    accuracy = 0;
    correct_num = 0;
    test_image_num = floder_test_image_num;
    i_num = zeros(10, 1);
    true_num = zeros(10, 1);
    for test_i = 1:length(floder_test_feature)
        i_feature_label = floder_test_feature(test_i,:);
        label_i = i_feature_label(1);
        i_feature = i_feature_label(2:length(i_feature_label));
        [result,v]=BayesLeasterror(i_feature', train_feature, train_num);
        if label_i == result
            correct_num = correct_num + 1;
            true_num(label_i + 1) = true_num(label_i + 1) + 1;
        end
        i_num(label_i + 1) = i_num(label_i + 1) + 1;
    end
    true_num
    accuracy = correct_num / test_image_num;
end
