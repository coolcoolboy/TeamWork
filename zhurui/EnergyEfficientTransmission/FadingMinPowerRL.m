% in this program, we test the reiningforce learning idea of fading channel for CRN based on
% Gaussian input. And, the different is we try to minimize the total transmition power

clear
clc

SNRdB=[0:2:10];
% 注意，这里我把SNR转为指数分布的参数
SnrEx=10.^(SNRdB./10);  
PtMax=20;
Ct=2;
T=5;
RepNum=1000;

QuizStep=0.00001; %this is corresponding with the SDP to avoid the numerical problem 

% this part is the parameter for SDP
CtStepLev=5;
QuizStep=0.01;
StateStep=Ct/(CtStepLev-1);
StateMatrix=[0:StateStep:Ct];
MontNum=100000;
for snrIter=1:length(SNRdB)
    SnrLem=SnrEx(snrIter);
    ExpMatrix1=zeros(CtStepLev,T);
    
    CuNumMatrix=zeros(CtStepLev,T);
%     采用双层循环减小内存的消耗
    for MontDoubInd=1:1000
        while true
            ChanFadCoffP=random('exp',0.1,1,MontNum*(T+20)); %20个冗余，保证去掉小于最小积分精度的，避免数值问题
            DelInd=find(ChanFadCoffP<QuizStep);
            ChanFadCoffP(DelInd)=[];
            if length(ChanFadCoffP)>=MontNum*T
                ChanFadCoff=reshape(ChanFadCoffP(1:MontNum*T),MontNum,T);
                break;
            end
        end     
        
        MontState=zeros(MontNum,T+1);
        MontState(:,1)=5; MontState(:,end)=1;
        for MontInd=1:MontNum
            for Tind=2:T
                MontState(MontInd,Tind)=random('unid', MontState(MontInd,Tind-1),1,1);
            end
        end
        TranC=fliplr(diff(fliplr(MontState),1,2))*StateStep;
        TranPow=((2.^(TranC)-1)./ChanFadCoff);
        PowerPartern1=fliplr(cumsum(fliplr(TranPow),2));
        for MontInd=1:MontNum
            for Tind=1:T
                CuNumMatrix(MontState(MontInd,Tind),Tind)=CuNumMatrix(MontState(MontInd,Tind),Tind)+1;
                TemptVal=(PowerPartern1(MontInd,Tind)-ExpMatrix1(MontState(MontInd,Tind),Tind))/CuNumMatrix(MontState(MontInd,Tind),Tind);
                ExpMatrix1(MontState(MontInd,Tind),Tind)=ExpMatrix1(MontState(MontInd,Tind),Tind)+TemptVal;
            end
        end
        CuNumMatrix
        ExpMatrix1
%         this is a record per MontNum times
        PowRecord1VsSnr(MontDoubInd)=PerfTest(ExpMatrix1,SnrLem,T,RepNum,CtStepLev,StateMatrix,StateStep)
    end
    PowRecord2VsSnr(snrIter)=mean(PowRecord1VsSnr);
end