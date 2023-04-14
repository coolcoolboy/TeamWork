function PowRecordVsSnr=PerfTest(ExpMatrix,SnrLem,T,RepNum,CtStepLev,StateMatrix,StateStep)

ExpMatrix=[ExpMatrix zeros(CtStepLev,1)];
ExpMatrix(:,1)=[];

ChanFadCoffMat=random('exp',SnrLem,RepNum,T);
PowRecord=zeros(RepNum,T);
for RepIter=1:RepNum
        ChanFadCoff=ChanFadCoffMat(RepIter,:);
        StateRec=zeros(1,T);
        StateRec(1)=CtStepLev;
        for Tind=1:T
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
        
        PowRecordVsSnr=mean(sum(PowRecord,2));
end
    