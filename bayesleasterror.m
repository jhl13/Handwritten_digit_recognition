function [result,v]=bayesleasterror(testfeature, template_feature, template_num)
% testfeature = (100, 1)
% template_feature = (num, 101) 第一个为类别，后100个为特征
% template_num = (10, 1)

Pw = zeros(10, 1); % 先验概率
P = zeros(10, 100); % wi类的 j个特征的均值
PwX = zeros(10, 1); % 后验概率

s_cov = []; %各类别协方差 (10, 100, 100)
s_inv = []; %协方差矩阵的逆 (10, 100, 100)
s_det = []; %协方差矩阵的行列式 (10, 100, 100)

[total_num, ~] = size(template_feature);
Pw = template_num / total_num;

for i=1:10
    for j=2:101
        class_index = template_feature(:, 1) == i-1;
        numof1 = sum(template_feature(class_index,j)==1);
        P(i,j) = (numof1+1)/(template_num(i)+2);
    end
    i_feature = template_feature(template_feature(:, 1) == i-1,:);
    s_cov(i).dat = cov(i_feature(:,2:101)); % 求各类别的协方差矩阵
    s_inv(i).dat = inv(s_cov(i).dat); % 求协方差矩阵的逆矩阵
    s_det(i) = det(s_cov(i).dat); % 求协方差矩阵的行列式
end

for i=1:10
    PwX(i) = (testfeature - P(i))' * s_inv(i).dat * (testfeature - P(i))...
        * (-0.5) + log(Pw(i)) + log(abs(s_det(i))) * (-0.5);
end
[v,result]=max(PwX);
result=result-1;
end
