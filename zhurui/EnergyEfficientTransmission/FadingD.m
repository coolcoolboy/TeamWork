 %         this is the direct trans

clear
clc

SNRdB=[0:2:0];
% snr=sqrt(PtMax./(10.^(SNRdB./10)))

PtMax=50;

Ct=2;
T=8;
PFix=10;
threshold=10e-5;
RepNum=10000;

for snrIter=1:length(SNRdB)    
    for RepIter=1:RepNum
        ChanFadCoff=random('exp',0.1,T,1);
    
        TemptTranP=(2^Ct-1)./ChanFadCoff(1);
        CPRadioDir(RepIter)=Ct./(PFix+TemptTranP);
    end  
end



