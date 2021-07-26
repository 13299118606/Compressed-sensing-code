function Demo_CS_OMP()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the DCT basis is selected as the sparse representation dictionary
% instead of seting the whole image as a vector, I process the image in the
% fashion of column-by-column, so as to reduce the complexity.
% ѡ��DCT����Ϊϡ���ʾ�ֵ䣬�����ǽ�����ͼ����Ϊ�������������еķ�ʽ��ͼ����д����Խ��͸��Ӷ�

% Author: Chengfu Huo, roy@mail.ustc.edu.cn, http://home.ustc.edu.cn/~roy
% Reference: J. Tropp and A. Gilbert, ��Signal Recovery from Random
% Measurements via Orthogonal Matching Pursuit,�� 2007.
% ���ף���������ƥ��׷�ٵ���������źŻָ� 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------ read in the image --------------
img=imread('lena.bmp');     % testing image
img=double(img);
[height,width]=size(img);


%------------ form the measurement matrix and base matrix ---------------  �γɲ�������ͻ�����
Phi=randn(floor(height/3),width);  % only keep one third of the original data
Phi = Phi./repmat(sqrt(sum(Phi.^2,1)),[floor(height/3),1]); % normalize each column ��һ��ÿһ��
% B = repmat(A,n) ����һ�����飬������������ά�Ⱥ���ά�Ȱ��� A �� n ��������A Ϊ����ʱ��B ��СΪ size(A)*n��
mat_dct_1d=zeros(256,256);  % building the DCT basis (corresponding to each column) ����DCT����(��Ӧÿһ��)
for k=0:1:255
    dct_1d=cos([0:1:255]'*k*pi/256);
    if k>0
        dct_1d=dct_1d-mean(dct_1d); % mean() -- ��ȡ�����ƽ����
    end
    mat_dct_1d(:,k+1)=dct_1d/norm(dct_1d);
end


%--------- projection ---------
img_cs_1d=Phi*img;          % treat each column as a independent signal ÿһ�ж���Ϊһ���������źţ�PhiΪ��������
                            % img_cs_1d=Phi*img,��Ϊ y=��x����Ϊ��������xΪԭʼ�źţ�yΪ�۲�ֵ

%-------- recover using omp ------------
%%%%%%%�� y=��s����֪���󦨣��ɻ��ϡ���źŵıƽ�ֵ��������x��= ��s������Ϊϡ������ɻ��ԭʼ�źŵıƽ�ֵ����ΪĿ����

sparse_rec_1d=zeros(height,width);  % sparse - ϡ��  ��height,width Ϊ������Ƭ���С��� ,256*256
Theta_1d=Phi*mat_dct_1d;  % �൱�� Theta_1d = �������� * DCTϡ��� �� �� Theta_1d Ϊ��֪�����ظ�����
for i=1:width  % 1:256
    column_rec=cs_omp(img_cs_1d(:,i),Theta_1d,height);
    sparse_rec_1d(:,i)=column_rec';         % sparse representation ϡ���ʾ��ֻ���ź���Kϡ��ģ���KС��MԶԶС��N����
    %���п����ڹ۲�M���۲�ֵʱ����K���ϴ��ϵ���ؽ�ԭʼ����ΪN���źţ�
    %���ָ������ݾ����С���֪����Ĵ�СΪ M * N
end %�˴����������ù۲�ֵ y �� ��֪���������ϡ���źŵıƽ�ֵ
img_rec_1d=mat_dct_1d*sparse_rec_1d;          % inverse transform ��任���ָ�������� img_rec_1d = DCTϡ��� * ϡ��ָ�����


%------------ show the results --------------------
figure(1)
subplot(2,2,1),imagesc(img),title('original image')
subplot(2,2,2),imagesc(Phi),title('measurement mat')   % ��������
subplot(2,2,3),imagesc(mat_dct_1d),title('1d dct mat') % ϡ���
psnr = 20*log10(255/sqrt(mean((img(:)-img_rec_1d(:)).^2)))
subplot(2,2,4),imagesc(img_rec_1d),title(strcat('1d rec img ',num2str(psnr),'dB'))

disp('over');


%************************************************************************%
function hat_x=cs_omp(y,T_Mat,m)
    % y=T_Mat*s, T_Mat is n-by-m ,T_Mat��Ϊ��֪����
    % y - measurements
    % T_Mat - combination of random matrix and sparse representation basis
    % m - size of the original signal������˵��Ϊԭʼͼ�������
    % the sparsity is length(y)/4 ϡ����ǹ۲�ֵ���ȵ��ķ�֮һ

    n=length(y); %��ҲΪ�����źŵĳ���
    s=floor(n/4);                                     %  ����ֵά����ϡ���
    hat_x=zeros(1,m);                                 %  ���ع�������(�任��)����
    Aug_t=[];                                         %  ��������(��ʼֵΪ�վ���)
    r_n=y;                                            %  �в�ֵ �в�������ͳ������ָʵ�ʹ۲�ֵ�����ֵ(���ֵ)֮��Ĳ�

    for times=1:s                                  %  ��������(ϡ����ǲ�����1/4)

        product=abs(T_Mat'*r_n);   % y = T_Mat*s,T_Mat �� M*N ,y �� M*1  ==> product �� s Ϊ N*1

        [val,pos]=max(product);                       %  ���ͶӰϵ����Ӧ��λ��
        Aug_t=[Aug_t,T_Mat(:,pos)];                   %  ��������
        T_Mat(:,pos)=zeros(n,1);                      %  ѡ�е������㣨ʵ����Ӧ��ȥ����Ϊ�˼򵥽������㣩
        aug_x=(Aug_t'*Aug_t)^(-1)*Aug_t'*y;           %  ��С����,ʹ�в���С,ϡ���źŵ���С���˹�����
        r_n=y-Aug_t*aug_x;                            %  �в�
        pos_array(times)=pos;                         %  ��¼���ͶӰϵ����λ��

    end
    hat_x(pos_array)=aug_x;                           %  �ع�������



