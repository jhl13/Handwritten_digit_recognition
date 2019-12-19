function [result,v]=bayesleasterror(testfeature, template_feature, template_num)
% testfeature = (100, 1)
% template_feature = (num, 101) ��һ��Ϊ��𣬺�100��Ϊ����
% template_num = (10, 1)

Pw = zeros(10, 1); % �������
P = zeros(10, 100); % wi��� j�������ľ�ֵ

s_cov = []; %�����Э����
s_inv = []; %Э����������
s_det = []; %Э������������ʽ

[total_num, ~] = size(template_feature);
Pw = template_num / total_num;

for i=1:10
    for j=2:101
        class_index = template_feature(:, 1) == i-1;
        numof1 = sum(template_feature(class_index,j)==1);
        P(i,j) = (numof1+1)/(template_num(i)+2);
    end
    i_feature = template_feature(template_feature(:, 1) == i-1,:);
    s_cov(i).dat = cov(i_feature(:,2:101));
end
end
