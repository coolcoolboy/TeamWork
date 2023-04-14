% in this program, we test the off idea of fading channel for CRN based on
% Gaussian input. And, we generate the training set for the AI
clear
clc

SNRdB=[0:2:0];
% snr=sqrt(PtMax./(10.^(SNRdB./10)))
snr=1;

PtMax=10;

Ct=2;
T=8;
PFix=10;
threshold=10e-5;
RepNum=10;

% This part is the parametre of SDP
ChanFadCoffPartern=[0.1 0.9];
ProOfChan=[0.5 0.5];
PowStep=PtMax./4;
PowLev=[0:PowStep:PtMax];
for snrIter=1:length(SNRdB)    
%     In this part, we try to establish the table of SDP
%     this is the Capacity table
    CapTable=ProOfChan(1)*log2(1+PowLev*ChanFadCoffPartern(1))+ProOfChan(2)*log2(1+PowLev*ChanFadCoffPartern(2))
    
    for TableInd=1:length(ChanFadCoffPartern)
        CapTableTempt=log2(1+PowLev*ChanFadCoffPartern(TableInd));
        for CapTabInd=1:length(CapTableTempt)
            TemptCapSum=CapTableTempt(CapTabInd)+CapTable;
            TemptInd1=find(TemptCapSum>Ct);
            [TemptCPRadio(TableInd,CapTabInd) TemptInd2]=max(TemptCapSum(TemptInd1)./(PowLev(CapTabInd)+PowLev(TemptInd1)));
            CapRecord=TemptCapSum(TemptInd1)
            PowRecord=
        end
        TemptCPRadio(TableInd,:)=TemptCPRadio(TableInd,:)*ProOfChan(TableInd);
    end
    [TemptVal TemptInd]=max(sum(TemptCPRadio));
    
    for RepIter=1:RepNum
        ChanFadCoff=random('exp',0.1,T,1);
        
        
    end  
end