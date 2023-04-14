% in this program, we test the off idea of fading channel for CRN based on
% Gaussian input. And, the different is we try to minimize the total transmition power
clear
clc

SNRdB=[0:2:10];
PtMax=20;
% 注意，这里我把SNR转为指数分布的参数
SnrEx=10.^(SNRdB./10);  

Ct=2;
T=8;
RepNum=100;

% this is the quizz parameter
PStep=10;

for snrIter=1:length(SNRdB)
    ChanFadCoffMat=random('exp',SnrEx(snrIter),RepNum,T);
    for RepIter=1:RepNum
        ChanFadCoff=ChanFadCoffMat(RepIter,:)';
        
%         this is the offline part, and it is also a upper bounder
        cvx_begin
            variable TransPower(T);
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
        [TemptQuazInd TemptQuazVal]=quantiz(TransPower,PtMax/PStep:PtMax/PStep:PtMax*(PStep-1)/PStep,PtMax/PStep:PtMax/PStep:PtMax);
        TransPowQuazMat(RepIter,:)=TemptQuazInd;                
        
% %         this is the greedy algorithm
%         TotalPower=0;
%         CtResume=Ct;
%         TranPower=zeros(1,T);
%         for SlotInd=1:T
%             TranPowerReq=(2^CtResume-1)/ChanFadCoff(SlotInd);            
%             if TranPowerReq < PtMax
%                 TranPower(SlotInd)=TranPowerReq;
%                 TotalPower=TotalPower+TranPower(SlotInd);
%                 break
%             else
%                 TranPower(SlotInd)=PtMax;
%                 TotalPower=TotalPower+PtMax;
%                 CtResume=Ct-log2(1+PtMax.*ChanFadCoff(SlotInd));
%             end
%         end
%         TransPowGreMat(RepIter,:)=TranPower;
%         TransPowGreSumMat(RepIter)=TotalPower;
    end
    OffOptPower(snrIter)=mean(TransPowOpSumMat);
    GreedPower(snrIter)=mean(TransPowGreSumMat);
%     %         In this part, we prepare the trainning data set.
%     TemptPar1=[T:-1:1];
%     TemptPar2=ones(RepNum,1);
%     SlotMat=kron(TemptPar1,TemptPar2);
%     TemptL1=reshape(SlotMat',RepNum*T,1)';
%     TemptL2=reshape(ReChanC',RepNum*T,1)';
%     TemptL4=reshape(TransPowQuazMat',RepNum*T,1)';
%     TemptL3=reshape(ChanFadCoffMa',RepNum*T,1)';
%         
%     OptP2Train=[TemptL1;TemptL2;TemptL3;TemptL4];
end

% save OptP2Train.mat OptP2Train