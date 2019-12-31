function [result,v]=BayesLeasterror(testfeature, template_feature, template_num)
% testfeature = (100, 1)
% template_feature = (num, 101) ��һ��Ϊ��𣬺�100��Ϊ����
% template_num = (10, 1)

Pw = zeros(10, 1); % �������
P = zeros(10, 25); % wi��� j�������ľ�ֵ
PwX = zeros(10, 1); % �������

s_cov = double([]); %�����Э���� (10, 100, 100)
s_inv = double([]); %Э���������� (10, 100, 100)
s_det = double([]); %Э������������ʽ (10, 100, 100)

[total_num, ~] = size(template_feature);
Pw = template_num / total_num;

for i=1:10
    for j=2:26
        class_index = template_feature(:, 1) == i-1;
        numof1 = sum(template_feature(class_index,j));
        P(i,j) = (numof1)/(template_num(i));
    end
    i_feature = template_feature(template_feature(:, 1) == i-1,:);
    s_cov(i).dat = cov(i_feature(:,2:26)); % �������Э�������
    s_inv(i).dat = pinv(s_cov(i).dat); % ��Э�������������
    s_det(i) = det(s_cov(i).dat); % ��Э������������ʽ
end

for i=1:10
    PwX(i) = (testfeature - P(i, 2:26)')' * s_inv(i).dat * (testfeature - P(i, 2:26)')...
        * (-0.5) + log(abs(s_det(i))) * (-0.5);
end
[v,result]=max(PwX);
result=result-1;
end
