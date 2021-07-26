function Phi = PartFourierMtx(M,N)%���ɸ���Ҷ��������
    % N = 6; M = 3;
    Phi_t = fft(eye(N,N))/sqrt(N);%Fourier matrix ,���ɸ���Ҷ��������
    RowIndex = randperm(N);
    Phi = Phi_t(RowIndex(1:M),:);%Select M rows randomly
%     normalization
    for ii = 1:N
        Phi(:,ii) = Phi(:,ii)/norm(Phi(:,ii));
    end
end