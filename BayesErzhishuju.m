function [result,v]=BayesErzhishuju(testfeature, template_feature, template_num)
% testfeature = (100, 1)
% template_feature = (num, 101) ��һ��Ϊ��𣬺�100��Ϊ����
% template_num = (10, 1)

Pw = zeros(10, 1); % �������
P = zeros(10, 100); % wi��� j������
PXw = zeros(10, 1); % ����������
PwX = zeros(10, 1); % �������

[total_num, ~] = size(template_feature);
Pw = template_num / total_num;

for i=1:10
    for j=2:101
        class_index = template_feature(:, 1) == i-1;
        numof1=sum(template_feature(class_index,j)==1);
        P(i,j)=(numof1+1)/(template_num(i)+2);
    end
end

for i=1:10
    Pcopy=P(i,2:101);
    index=find(testfeature==0);
    Pcopy(index)=1-Pcopy(index);
    PXw(i)=prod(Pcopy,2);
end
PX=sum(Pw.*PXw);
PwX=(Pw.*PXw)/PX;
[v,result]=max(PwX);
result=result-1;
end

