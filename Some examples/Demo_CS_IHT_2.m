
% ѹ����֪�ع��㷨֮����Ӳ��ֵ(Iterative Hard Thresholding,IHT)������������
clear all;close all;clc;      
M = 64;%�۲�ֵ����      
N = 256;%�ź�x�ĳ���      
K = 30;%�ź�x��ϡ���      
Index_K = randperm(N);      
x = zeros(N,1);      
% x(Index_K(1:K)) = 5*randn(K,1);%xΪKϡ��ģ���λ���������    
x(Index_K(1:K)) = 1;
Psi = eye(N);%x������ϡ��ģ�����ϡ�����Ϊ��λ��x=Psi*theta      
Phi = randn(M,N);%��������Ϊ��˹����  
Phi = orth(Phi')';    
A = Phi * Psi;%���о���    
% sigma = 0.005;    
% e = sigma*randn(M,1);  
% y = Phi * x + e;%�õ��۲�����y      
y = Phi * x;%�õ��۲�����y    
%% �ָ��ع��ź�x      
tic  
theta = CS_IHT_2(y,A,K); 
% theta = IHT_Basic(y,A,K); 
% theta = cs_iht(y,A,size(A,2));
% theta = hard_l0_Mterm(y,A,size(A,2),round(1.5*K),'verbose',true);
x_r = Psi * theta;% x=Psi * theta      
toc      
%% ��ͼ      
figure;      
plot(x_r,'k.-');%���x�Ļָ��ź�      
hold on;      
plot(x,'r');%���ԭ�ź�x      
hold off;      
legend('Recovery','Original')      
fprintf('\n�ָ��в');      
norm(x_r-x)%�ָ��в�  
[n1,r1] = biterr(x,round(x_r));