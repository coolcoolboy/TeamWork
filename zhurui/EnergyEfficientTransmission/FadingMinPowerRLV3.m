% in this program, we test the reiningforce learning idea of fading channel for CRN based on
% Gaussian input. And, the different is we use the TD method instead of the MC.

clear
clc

SNRdB=[0:2:0];
PtMax=20;
Ct=2;
T=5;

QuizStep=0.00001; %this is corresponding with the SDP to avoid the numerical problem 

% this part is the parameter for SDP
CtStepLev=5;
QuizStep=0.01;
StateStep=Ct/(CtStepLev-1);
StateMatrix=[0:StateStep:Ct];
RepNum=100;

DecayWeight=0.9;
for snrIter=1:length(SNRdB)
    SnrLem=0.1
    
    ExpMatrix1=zeros(CtStepLev,T);
    CuNumMatrix=zeros(CtStepLev,T);
    Epsilon=0.5;
    Alpha=0.5;
%     采用双层循环减小内存的消耗
    for MontDoubInd=1:1000
        Epsilon=Epsilon*DecayWeight;
        Alpha=Alpha*DecayWeight;
        for MontInInd=1:1000
        while true
            ChanFadCoffP=random('exp',0.1,1,(T+20)); %20个冗余，保证去掉小于最小积分精度的，避免数值问题
            DelInd=find(ChanFadCoffP<QuizStep);
            ChanFadCoffP(DelInd)=[];
            if length(ChanFadCoffP)>=T
                ChanFadCoff=reshape(ChanFadCoffP(1:T),1,T);
                break;
            end
        end     
        
        MontState=zeros(1,T+1);
        MontState(:,1)=5; MontState(:,end)=1;
        MontAct=zeros(1,T+1);
        for Tind=2:T
            if random('unif', 0,1,1,1)>Epsilon
                ActState=(MontState(1,Tind-1)-1)*StateStep;
                NextStateInd=(ActState-StateMatrix(1:MontState(1,Tind-1)))/StateStep+1;
                TemptPow=(2.^(StateMatrix(1:MontState(1,Tind-1)))-1)./ChanFadCoff(Tind-1);
                AntiPow=TemptPow'+ExpMatrix1(NextStateInd,Tind);
                [minAntiPow NextState]=min(AntiPow);
                MontState(1,Tind)=NextStateInd(NextState);
                ExpMatrix1(MontState(1,Tind-1),Tind-1)=ExpMatrix1(MontState(1,Tind-1),Tind-1)+Alpha*(minAntiPow-ExpMatrix1(MontState(1,Tind-1),Tind-1));
            else
                MontState(1,Tind)=random('unid', MontState(1,Tind-1),1,1);
                ActIs=(MontState(1,Tind-1)-MontState(1,Tind))*StateStep;
                TemptPow=(2.^(ActIs)-1)./ChanFadCoff(Tind-1);
                ExpMatrix1(MontState(1,Tind-1),Tind-1)=ExpMatrix1(MontState(1,Tind-1),Tind-1)+Alpha*(TemptPow+ExpMatrix1(MontState(1,Tind),Tind)-ExpMatrix1(MontState(1,Tind-1),Tind-1));
            end
        end
        TemptPow=((2^(MontState(1,T)-1)-1)*StateStep)/ChanFadCoff(T);
        ExpMatrix1(MontState(1,T),T)=ExpMatrix1(MontState(1,T),T)+Alpha*(TemptPow-ExpMatrix1(MontState(1,T),T));
        end    
%         CuNumMatrix        
        ExpMatrix1
        PowRecordVsSnr=PerfTest(ExpMatrix1,SnrLem,T,RepNum,CtStepLev,StateMatrix,StateStep);
        [Alpha Epsilon PowRecordVsSnr]
    end
end