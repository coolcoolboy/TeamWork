% in this program, we test the reiningforce learning idea of fading channel for CRN based on
% Gaussian input. And, the different is we use the epsilon on line strategy.
% based on the states setting, the action is also soft greedy.

clear
clc

SNRdB=[4];
% 注意，这里我把SNR转为指数分布的参数
SnrEx=10.^(SNRdB./10);  
PtMax=20;
Ct=2;
T=[3:8];

% this part is the parameter for SDP
CtStepLev=5;
QuizStep=0.01;  %this is corresponding with the SDP to avoid the numerical problem 
StateStep=Ct/(CtStepLev-1);
StateMatrix=[0:StateStep:Ct];
RepNum=1000;

DecayWeight=0.99;
for TIter=1:length(T)
    SnrLem=SnrEx;
    
    ExpMatrix1=zeros(CtStepLev,T(TIter));
    CuNumMatrix=zeros(CtStepLev,T(TIter));
    Epsilon=0.5;
%     采用双层循环减小内存的消耗
    for MontDoubInd=1:100
        Epsilon=Epsilon*DecayWeight;
        for MontInInd=1:100
        while true
            ChanFadCoffP=random('exp',SnrLem,1,(T(TIter)+20)); %20个冗余，保证去掉小于最小积分精度的，避免数值问题
            DelInd=find(ChanFadCoffP<QuizStep);
            ChanFadCoffP(DelInd)=[];
            if length(ChanFadCoffP)>=T(TIter)
                ChanFadCoff=reshape(ChanFadCoffP(1:T(TIter)),1,T(TIter));
                break;
            end
        end     
        
        MontState=zeros(1,T(TIter)+1);
        MontState(:,1)=5; MontState(:,end)=1;
        MontAct=zeros(1,T(TIter)+1);
        for Tind=2:T(TIter)
            if random('unif', 0,1,1,1)>Epsilon
                ActState=(MontState(1,Tind-1)-1)*StateStep;
                NextStateInd=(ActState-StateMatrix(1:MontState(1,Tind-1)))/StateStep+1;
                TemptPow=(2.^(StateMatrix(1:MontState(1,Tind-1)))-1)./ChanFadCoff(Tind-1);
                AntiPow=TemptPow'+ExpMatrix1(NextStateInd,Tind);
                [minAntiPow NextState]=min(AntiPow);
                MontState(1,Tind)=NextStateInd(NextState);
            else
                MontState(1,Tind)=random('unid', MontState(1,Tind-1),1,1);
            end
        end
        
        MontAct=fliplr(diff(fliplr(MontState),1,2))+1;
        TranC=(MontAct-1)*StateStep;
        TranPow=((2.^(TranC)-1)./ChanFadCoff);
        PowerPartern1=fliplr(cumsum(fliplr(TranPow),2));
        for Tind=1:T(TIter)
            CuNumMatrix(MontState(1,Tind),Tind)=CuNumMatrix(MontState(1,Tind),Tind)+1;
            TemptVal=(PowerPartern1(1,Tind)-ExpMatrix1(MontState(1,Tind),Tind))/CuNumMatrix(MontState(1,Tind),Tind);
            ExpMatrix1(MontState(1,Tind),Tind)=ExpMatrix1(MontState(1,Tind),Tind)+TemptVal;
        end
        end    
        CuNumMatrix;
        ExpMatrix1;
%         this is a record per MontNum times
        PowRecord1VsT(TIter)=PerfTest(ExpMatrix1,SnrLem,T(TIter),RepNum,CtStepLev,StateMatrix,StateStep)
    end
end