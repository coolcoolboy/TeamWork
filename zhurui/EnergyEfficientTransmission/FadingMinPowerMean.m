% in this program, we test the off idea of fading channel for CRN based on
% Gaussian input. And, this is the normal idea 2,
% 我想通过分布的均值进行功率分配，如果分布不变，就相当于每个时隙平均传输。
clear
clc

SNRdB=[0:2:10];
PtMax=20;
% 注意，这里我把SNR转为指数分布的参数
SnrEx=10.^(SNRdB./10);  

Ct=2;
T=8;
MeanCt=Ct/T;
RepNum=10000;

for snrIter=1:length(SNRdB)
    ChanFadCoffMat=random('exp',SnrEx(snrIter),RepNum,T);
    for RepIter=1:RepNum
        ChanFadCoff=ChanFadCoffMat(RepIter,:)';
        TranPower=(2^MeanCt-1)./ChanFadCoff;            
        TransPowGreMat(RepIter,:)=TranPower;
        TransPowGreSumMat(RepIter)=sum(TranPower);
    end
    MeanIdeaPower(snrIter)=mean(TransPowGreSumMat);
end