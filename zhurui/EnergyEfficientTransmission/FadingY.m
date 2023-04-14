% in this program, we test the off idea of fading channel for CRN based on
% Gaussian input. And, we generate the training set for the AI
clear
clc

SNRdB=[0:2:0];
% snr=sqrt(PtMax./(10.^(SNRdB./10)))

PtMax=5;

Ct=2;
T=8;
PFix=10;
threshold=10e-5;
RepNum=10;

for snrIter=1:length(SNRdB)    
    for RepIter=1:RepNum
        ChanFadCoff=random('exp',0.1,T,1);
        CPRadio=0.001;
        CPRadioUppBo=1000;
        CRRadioLowBo=0;
        IterSign=1;
    
        while IterSign==1
            cvx_begin
                variable TransPower(T);
                ChanC=log(1+TransPower.*ChanFadCoff);
                minimize CPRadio;    
                subject to              
                    sum(ChanC)>=Ct;
                    sum(ChanC)>=CPRadio*(PFix+sum(TransPower));
                    0<=TransPower<=PtMax
            cvx_end    
            if strcmpi('Solved',cvx_status)==1||strcmpi('Inaccurate/Solved',cvx_status)==1;
                CRRadioLowBo=CPRadio;
                CPRadioOld=CPRadio;
                CPRadio=(CPRadioUppBo+CRRadioLowBo)./2;
            else 
                CPRadioUppBo=CPRadio;
                CPRadioOld=CPRadio;
                CPRadio=(CPRadioUppBo+CRRadioLowBo)./2;        
            end
        
            if (abs(CPRadioOld-CPRadio)<threshold);
                if (strcmpi('Solved',cvx_status)==1)||strcmpi('Inaccurate/Solved',cvx_status)==1;
                    IterSign=0;
                end
            end
            
            if CPRadio<threshold
                ChanFadCoff=random('exp',0.1,T,1);
            end
        end
        CPRadioMatOld(RepIter,:)=CPRadioOld;
        
        TransPowMat(RepIter,:)=TransPower;
        FinChanC=log2(1+TransPower.*ChanFadCoff);
        CPRadioMat(RepIter,:)=sum(FinChanC)./(sum(TransPowMat(RepIter,:))+PFix);
        

        
%         TemptChan=Ct-cumsum(FinChanC');
%         ReChanC(RepIter,:)=[Ct TemptChan(1:end-1)];
%         ChanFadCoffMa(RepIter,:)=ChanFadCoff';
%         TemptQuaz=quantiz(TransPower,PtMax/10:PtMax/10:PtMax*9/10,1:10);
%         TransPowQuazMat(RepIter,:)=TemptQuaz;
    end  
end