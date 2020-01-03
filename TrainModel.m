% Train a ANN model

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
%mean_data = mean(train_data(:, 2:26));
train_data(:, 2:26) = train_data(:, 2:26) - mean_data;
train_data_shuffle = train_data(randperm(size(train_data, 1)), :);

i = 1;
image_per_class = 30;
validate_data = double(zeros(class * image_per_class, 26));
for num=1:class
    for n=121:(120+image_per_class)
        eval(['imagedata=imread(''E:\matlab_project\matlab_project\100_digit\' num2str(num-1) '\' num2str(num-1) '_' num2str(n) '.jpg'');'])
        thresh=graythresh(imagedata);%确定二值化阈值
        imagedata=im2bw(imagedata,thresh);%对图像二值化
        [feature, featureimg] = getfeature(reshape(imagedata, [28,28]), 1);
        validate_data(i, :) = [num - 1; feature];
        i = i + 1;
    end
end
validate_data(:, 2:26) = validate_data(:, 2:26) - mean_data;

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

% Initiate weight
input_size = 25;
hidden_size = 40;
output_size = 10;
std = 0.1;

w1 = std .* normrnd(0, 1, input_size, hidden_size);
%w1 = randn(25, 30);
% b1 = zeros(1, 5);
theta1 = double(zeros(1, hidden_size));

w2 = std .* normrnd(0, 1, hidden_size, 10);
%w2 = randn(30, 10);
% b2 = zeros(1, 10);
theta2 = double(zeros(1, 10));

% forward_1 = double(zeros(1, 5));
% forward_2 = double(zeros(1, 10));

% Training
batch_size = 6;
epoch = 10000;
learning_rate = 0.01;
train_data_shuffle_size = size(train_data_shuffle);
step_per_epoch = fix(train_data_shuffle_size(1) / batch_size);

best_validate_acc = 0;
acc_plot = [];
validate_plot = [];

for k = 1:epoch
    if k > 0.8 * epoch
        learning_rate = 0.1;
    end
    train_data_shuffle = train_data(randperm(size(train_data, 1)), :);
    for i = 1:step_per_epoch
        batch_data = train_data_shuffle(((i -1)*batch_size + 1):((i)*batch_size), 2:26);
        batch_label = train_data_shuffle(((i -1)*batch_size + 1):((i)*batch_size), 1);
        % y is a vector of labels
        label_one_hot = zeros(size(batch_label, 1 ), class);
        weight_one_hot = ones(size(batch_label, 1 ), class);
        % assuming class labels start from one
        for j = 1:class
            rows = batch_label == j - 1;
            label_one_hot(rows, j) = 1;
            weight_one_hot(rows, j) = 2;
        end
        % calculate loss and gradients
        batch_loss = 0;
        batch_deta_w2 = double(zeros(hidden_size, 10));
        batch_deta_w1 = double(zeros(input_size, hidden_size));
        batch_deta_theta2 = double(zeros(1, 10));
        batch_deta_theta1 = double(zeros(1, hidden_size));
        acc = 0;
        for data_index = 1:batch_size
            % loss
            if unifrnd(0,1) < 0.5
                single_forward_1 = (batch_data(data_index, :) + (0.1 .* normrnd(0, 1, 1, input_size))) * w1;
            else
                single_forward_1 = batch_data(data_index, :) * w1;
            end
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
            g = (single_forward_2_sigmoid .* weight_one_hot(data_index, :) .* (1 - single_forward_2_sigmoid .* weight_one_hot(data_index, :)) .* (label_one_hot(data_index, :) - single_forward_2_sigmoid));
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
        acc = acc / batch_size;
    end
    
    if mod(k, 3) == 0
        validate_acc = 0;
        for validate_i = 1:size(validate_data,1)
            single_forward_1 = validate_data(validate_i, 2:26) * w1;
            single_forward_1_sigmoid = 1 ./ (1 + exp(-single_forward_1 + theta1));
            single_forward_2 = single_forward_1_sigmoid * w2;
            single_forward_2_sigmoid = 1 ./ (1 + exp(-single_forward_2 + theta2));
            [score, prediction] = max(single_forward_2_sigmoid);
            if (prediction - 1) == validate_data(validate_i, 1)
                validate_acc = validate_acc + 1;
            end
        end
        validate_acc = validate_acc / size(validate_data,1)
        k
        acc_plot = [acc_plot; acc];
        validate_plot = [validate_plot, validate_acc];
        if best_validate_acc < validate_acc
            best_w2 = w2;
            best_w1 = w1;
            best_theta1 = theta1;
            best_theta2 = theta2;
            best_validate_acc = validate_acc;
        end
    end
end

w2 = best_w2;
w1 = best_w1;
theta1 = best_theta1;
theta2 = best_theta2;
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
best_validate_acc
test_acc = test_acc / size(test_data,1)
eval('save model_best_120.mat w1 w2 theta1 theta2')
eval('save result_120.mat best_validate_acc test_acc')

eval('k = 1:size(validate_plot, 2); plot(k, validate_plot); hold on; plot(k, acc_plot); ')
saveas(gcf, 'acc_120', 'png')