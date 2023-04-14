% in this program, we test the off idea of fading channel for CRN based on
% Gaussian input. And, the different is we try to minimize the total transmition power
clear
clc

SNRdB=[4];
PtMax=20;
% 注意，这里我把SNR转为指数分布的参数
SnrEx=10.^(SNRdB./10);  

Ct=2;
T=[3:8];
RepNum=100;

% this is the quizz parameter
PStep=10;

for TIter=1:length(T)
    ChanFadCoffMat=random('exp',SnrEx,RepNum,T(TIter));
    for RepIter=1:RepNum
        ChanFadCoff=ChanFadCoffMat(RepIter,:)';
        
%         this is the offline part, and it is also a upper bounder
        cvx_begin
            variable TransPower(T(TIter));
            ChanC=log(1+TransPower.*ChanFadCoff);
            minimize sum(TransPower);    
            subject to              
                sum(ChanC)>=log(2^Ct);
                0<=TransPower<=PtMax
        cvx_end    
        
        TransPowOpMat(RepIter,:)=TransPower;
        TransPowOpSumMat(RepIter)=sum(TransPower);
        FinChanC=log2(1+TransPower.*ChanFadCoff);
%         CPRadioMat(RepIter,:)=sum(FinChanC)./(sum(TransPowOpMat(RepIter,:))+PFix);
        TemptChan=Ct-cumsum(FinChanC);
        ReChanC(RepIter,:)=[Ct TemptChan(1:end-1)'];
        ChanFadCoffMa(RepIter,:)=ChanFadCoff';                
    end
    OffOptPower(TIter)=mean(TransPowOpSumMat);
end

