% Test model
% Load data
i = 1;
class = 10;
image_per_class = 120;
train_data = double(zeros(class * image_per_class, 26));
for num=1:class
    for n=1:image_per_class
        eval(['imagedata=imread(''E:\matlab_project\matlab_project\100_digit\' num2str(num-1) '\' num2str(num-1) '_' num2str(n) '.jpg'');'])
        thresh=graythresh(imagedata);%确定二值化阈值
        imagedata=im2bw(imagedata,thresh);%对图像二值化
        [feature, featureimg] = getfeature(reshape(imagedata, [28,28]), 1);
        %imagedata = reshape(imagedata, [10*10,1]);
        train_data(i, :) = [num - 1; feature];
        i = i + 1;
    end
end
mean_data = mean(train_data(:, 2:26));
% train_data(:, 2:26) = train_data(:, 2:26) - mean_data;

i = 1;
image_per_class = 30;
test_data = double(zeros(class * image_per_class, 26));
for num=1:class
    for n=121:(120+image_per_class)
        eval(['imagedata=imread(''E:\matlab_project\matlab_project\100_digit\' num2str(num-1) '\' num2str(num-1) '_' num2str(n) '.jpg'');'])
        thresh=graythresh(imagedata);%确定二值化阈值
        imagedata=im2bw(imagedata,thresh);%对图像二值化
        [feature, featureimg] = getfeature(reshape(imagedata, [28,28]), 1);
        test_data(i, :) = [num - 1; feature];
        i = i + 1;
    end
end
test_data(:, 2:26) = test_data(:, 2:26) - mean_data;

model = load('model_best_120.mat');
w1 = model.w1;
w2 = model.w2;
theta1 = model.theta1;
theta2 = model.theta2;
test_acc = 0;
for test_i = 1:size(test_data,1)
    single_forward_1 = test_data(test_i, 2:26) * w1;
    single_forward_1_sigmoid = 1 ./ (1 + exp(-single_forward_1 + theta1));
    single_forward_2 = single_forward_1_sigmoid * w2;
    single_forward_2_sigmoid = 1 ./ (1 + exp(-single_forward_2 + theta2));
    [score, prediction] = max(single_forward_2_sigmoid);
    if (prediction - 1) == test_data(test_i, 1)
        test_acc = test_acc + 1;
    end
end

test_acc = test_acc / size(test_data,1)

