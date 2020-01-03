% Train a ANN model

% Load data
i = 1;
class = 10;
image_per_class = 80;
train_data = double(zeros(class * image_per_class, 26));
for num=1:class
    for n=1:image_per_class
        eval(['imagedata=imread(''E:\matlab_project\matlab_project\100_digit\' num2str(num-1) '\' num2str(num-1) '_' num2str(n) '.jpg'');'])
        thresh=graythresh(imagedata);%确定二值化阈值
        imagedata=im2bw(imagedata,thresh);%对图像二值化
        [feature, featureimg] = getfeature(reshape(imagedata, [28,28]), 1);
        %imagedata = reshape(imagedata, [28*28,1]);
        train_data(i, :) = [num - 1; feature];
        i = i + 1;
    end
end
train_data_shuffle = train_data(randperm(size(train_data, 1)), :);

i = 1;
image_per_class = 30;
validata_data = double(zeros(class * image_per_class, 26));
for num=1:class
    for n=81:(80+image_per_class)
        eval(['imagedata=imread(''E:\matlab_project\matlab_project\100_digit\' num2str(num-1) '\' num2str(num-1) '_' num2str(n) '.jpg'');'])
        thresh=graythresh(imagedata);%确定二值化阈值
        imagedata=im2bw(imagedata,thresh);%对图像二值化
        [feature, featureimg] = getfeature(reshape(imagedata, [28,28]), 1);
        validata_data(i, :) = [num - 1; feature];
        i = i + 1;
    end
end

i = 1;
image_per_class = 40;
test_data = double(zeros(class * image_per_class, 26));
for num=1:class
    for n=111:(110+image_per_class)
        eval(['imagedata=imread(''E:\matlab_project\matlab_project\100_digit\' num2str(num-1) '\' num2str(num-1) '_' num2str(n) '.jpg'');'])
        thresh=graythresh(imagedata);%确定二值化阈值
        imagedata=im2bw(imagedata,thresh);%对图像二值化
        [feature, featureimg] = getfeature(reshape(imagedata, [28,28]), 1);
        test_data(i, :) = [num - 1; feature];
        i = i + 1;
    end
end

% Initiate weight
input_size = 25;
hidden_size = 28;
output_size = 10;
std = 1;

%w1 = std .* normrnd(0, 1, 784, 28);
w1 = randn(25, 28);
% b1 = zeros(1, 5);
theta1 = double(zeros(1, 28));

%w2 = std .* normrnd(0, 1, 28, 10);
w2 = randn(28, 10);
% b2 = zeros(1, 10);
theta2 = double(zeros(1, 10));

% forward_1 = double(zeros(1, 5));
% forward_2 = double(zeros(1, 10));

% Training
batch_size = 16;
epoch = 100;
learning_rate = 0.1;
train_data_shuffle_size = size(train_data_shuffle);
step_per_epoch = fix(train_data_shuffle_size(1) / batch_size);
best_acc = 0;

for k = 1:2400
    for i = 1:step_per_epoch
        batch_data = train_data_shuffle(((i -1)*batch_size + 1):((i)*batch_size), 2:26);
        batch_label = train_data_shuffle(((i -1)*batch_size + 1):((i)*batch_size), 1);
        % y is a vector of labels
        label_one_hot = zeros(size(batch_label, 1 ), class);
        % assuming class labels start from one
        for j = 1:class
            rows = batch_label == j - 1;
            label_one_hot(rows, j) = 1;
        end
        % calculate loss and gradients
        batch_loss = 0;
        batch_deta_w2 = double(zeros(28, 10));
        batch_deta_w1 = double(zeros(25, 28));
        batch_deta_theta2 = double(zeros(1, 10));
        batch_deta_theta1 = double(zeros(1, 28));
        acc = 0;
        for data_index = 1:batch_size
            % loss
            single_forward_1 = batch_data(data_index, :) * w1;
            single_forward_1_sigmoid = 1 ./ (1 + exp(-single_forward_1 + theta1));
            single_forward_2 = single_forward_1_sigmoid * w2;
            single_forward_2_sigmoid = 1 ./ (1 + exp(-single_forward_2 + theta2));
            single_loss = 0.5 * sum((label_one_hot(data_index, :) - single_forward_2_sigmoid).^2);
            [score, prediction] = max(single_forward_2_sigmoid);
            [xxx, label] = max(label_one_hot(data_index, :));
            if prediction == label
                acc = acc + 1;
            end
            batch_loss = batch_loss + single_loss;
            % gradients
            g = (single_forward_2_sigmoid .* (1 - single_forward_2_sigmoid) .* (label_one_hot(data_index, :) - single_forward_2_sigmoid));
            e = (single_forward_1_sigmoid .* (1 - single_forward_1_sigmoid) .* (g * w2'));
            single_deta_w2 = learning_rate .* single_forward_1_sigmoid' * g;
            batch_deta_w2 = batch_deta_w2 + single_deta_w2;
            single_deta_theta2 = -learning_rate .* g;
            batch_deta_theta2 = batch_deta_theta2 + single_deta_theta2;
            single_deta_w1 = learning_rate .* batch_data(data_index, :)' * e;
            batch_deta_w1 = batch_deta_w1 + single_deta_w1;
            single_deta_theta1 = -learning_rate .* e;
            batch_deta_theta1 = batch_deta_theta1 + single_deta_theta1;
        end
        batch_loss = batch_loss / batch_size;
        batch_deta_w2 = batch_deta_w2 ./ batch_size;
        batch_deta_w1 = batch_deta_w1 ./ batch_size;
        batch_deta_theta2 = batch_deta_theta2 ./ batch_size;
        batch_deta_theta1 = batch_deta_theta1 ./ batch_size;
        w2 = w2 + batch_deta_w2;
        w1 = w1 + batch_deta_w1;
        theta1 = theta1 + batch_deta_theta1;
        theta2 = theta2 + batch_deta_theta2;
        acc = acc / batch_size
    end
    for 
end


