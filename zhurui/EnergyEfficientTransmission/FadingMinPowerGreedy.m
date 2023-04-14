% in this program, we test the off idea of fading channel for CRN based on
% Gaussian input. And, this is the normal idea 1
clear
clc

SNRdB=[0:2:10];
PtMax=20;
% 注意，这里我把SNR转为指数分布的参数
SnrEx=10.^(SNRdB./10);  

Ct=2;
T=8;
RepNum=10000;

for snrIter=1:length(SNRdB)
    ChanFadCoffMat=random('exp',SnrEx(snrIter),RepNum,T);
    for RepIter=1:RepNum
        ChanFadCoff=ChanFadCoffMat(RepIter,:)';
    
    %       this is the greedy algorithm
        TotalPower=0;
        CtResume=Ct;
        TranPower=zeros(1,T);
        for SlotInd=1:T
            TranPowerReq=(2^CtResume-1)/ChanFadCoff(SlotInd);            
            if TranPowerReq < PtMax
                TranPower(SlotInd)=TranPowerReq;
                TotalPower=TotalPower+TranPower(SlotInd);
                break
            else
                TranPower(SlotInd)=PtMax;
                TotalPower=TotalPower+PtMax;
                CtResume=Ct-log2(1+PtMax.*ChanFadCoff(SlotInd));
            end
        end
        TransPowGreMat(RepIter,:)=TranPower;
        TransPowGreSumMat(RepIter)=TotalPower;
    end
    GreedPower(snrIter)=mean(TransPowGreSumMat);
end


