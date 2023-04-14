% in this program, we test the SDP idea of fading channel for CRN based on
% Gaussian input. And, the different is we try to minimize the total transmition power
clear
clc

SNRdB=[4];
% 注意，这里我把SNR转为指数分布的参数
SnrEx=10.^(SNRdB./10);  
PtMax=20;
Ct=2;
T=[3:8];
RepNum=10000;

% this part is the parameter for SDP
CtStepLev=5;
QuizStep=0.01;
StateStep=Ct/(CtStepLev-1);
StateMatrix=[0:StateStep:Ct];

for TIter=1:length(T)
    SnrLem=SnrEx;
    
    ExpMatrix=zeros(CtStepLev,T(TIter));       
    QuizVec=[QuizStep:QuizStep:100];
    for StateInd=2:CtStepLev
        QuizPar=((2.^(StateMatrix(StateInd))-1)./QuizVec)/SnrLem.*exp(-QuizVec/SnrLem);
        ExpMatrix(StateInd,T)=QuizStep.*trapz(QuizPar);
    end
    for Tind=T(TIter)-1:-1:1
        for StateInd=2:CtStepLev
            TemptMatrix=[];
            for  NextInd=1:1:StateInd
                QuizPar=((2.^(StateMatrix(StateInd)-StateMatrix(NextInd))-1)./QuizVec)/SnrLem.*exp(-QuizVec/SnrLem);
                TemptExpVal= QuizStep.*trapz(QuizPar)+ExpMatrix(NextInd,Tind+1);
                TemptMatrix=[TemptMatrix TemptExpVal];
            end
            ExpMatrix(StateInd,Tind)=mean(TemptMatrix);            
        end
    end
%     注意，其实第一列没有用，最后一列由于没有后续状态应该是全0.
    ExpMatrix=[ExpMatrix zeros(CtStepLev,1)];
    ExpMatrix(:,1)=[];
%     this is the test part
    ChanFadCoffMat=random('exp',SnrLem,RepNum,T(TIter));
    PowRecord=zeros(RepNum,T(TIter));
    for RepIter=1:RepNum
        ChanFadCoff=ChanFadCoffMat(RepIter,:);
        StateRec=zeros(1,T(TIter));
        StateRec(1)=CtStepLev;
        for Tind=1:T(TIter)
            NextStateInd=(StateMatrix(StateRec(Tind))-StateMatrix(1:StateRec(Tind)))/StateStep+1;
            TemptPow=(2.^(StateMatrix(1:StateRec(Tind)))-1)./ChanFadCoff(Tind);
            AntiPow=TemptPow'+ExpMatrix(NextStateInd,Tind);
            [minAntiPow NextState]=min(AntiPow);
            PowRecord(RepIter,Tind)=TemptPow(NextState);
            StateRec(Tind+1)=NextStateInd(NextState);            
            if NextStateInd(NextState)==1
                break;
            end
        end
    end
    PowRecordVsT(TIter)=mean(sum(PowRecord,2));
end
