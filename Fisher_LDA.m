function [result,v]=Fisher_LDA(testfeature, template_feature, template_num)
% testfeature = (100, 1)
% template_feature = (num, 101) 第一个为类别，后100个为特征
% template_num = (10, 1)
P_i = zeros(10, 100); % wi类的 j个特征的均值
P_other = zeros(10, 25); % wi类的 j个特征的均值
s_i_cov = []; %各类别协方差 (10, 100, 100)
s_other_cov = []; %其余九类别协方差 (10, 100, 100)
Pw = zeros(10, 1); % 先验概率

[total_num, ~] = size(template_feature);
Pw = template_num / total_num;

for i=1:10
    for j=2:26
        class_index = template_feature(:, 1) == i-1;
        numof1=sum(template_feature(class_index,j));
        P_i(i,j)=(numof1)/(template_num(i));
        
        class_index = template_feature(:, 1) ~= i-1;
        numof1=sum(template_feature(class_index,j));
        P_other(i,j)=(numof1)/((sum(template_num) - template_num(i)));
    end
    i_feature = template_feature(template_feature(:, 1) == i-1,:);
    s_i_cov(i).dat = cov(i_feature(:,2:26)); % 求各类别的协方差矩阵
    i_other_feature = template_feature(template_feature(:, 1) ~= i-1,:);
    s_other_cov(i).dat = cov(i_other_feature(:,2:26)); % 其余九类别的协方差矩阵
end

confidence = zeros(10,1);
for i=1:10
    s_w = (template_num(i) * s_i_cov(i).dat + ...
        (sum(template_num) - template_num(i)) * s_other_cov(i).dat) / sum(template_num);
    w = pinv(s_w) * (P_i(i,2:26) - P_other(i,2:26))';
    w0 = -(1/2) * (P_i(i,2:26) + P_other(i,2:26)) * pinv(s_w) * (P_i(i,2:26) - P_other(i,2:26))' - log((1 - Pw(i))/Pw(i));
    g_test = w' * testfeature + w0;
    confidence(i) = g_test;
end

[v,result]=max(confidence);
result = result - 1;
end

