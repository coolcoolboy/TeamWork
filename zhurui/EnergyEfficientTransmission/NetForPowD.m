% P = [0 1 2 3 4 5 6 7 8 9 10];%Training Patterns (domain values)
% T = [0 1 2 3 4 3 2 1 2 3 4];%Training Targets (range values)

load('OptP2Train.mat')
Condi=OptP2Train(1:3,:);
Label=OptP2Train(4,:)+1;

% this is the trainning  and test data
P=Condi(:,1:end-80);
Pt=Condi(:,end-80+1:end);
Target=Label(:,1:end-80);
Tt=Label(:,end-80+1:end);

T=zeros(10,length(Target));
for iterInd=1:length(Target)
    T(Target(iterInd),iterInd)=1;
end



net = newff(minmax(P),[100 10],{'tansig' 'logsig'});
%Train the network and plot the results
net.trainParam.goal=0.01; %0 is the default- too small!
net.trainParam.epochs = 100; %For our sample, don¡¯t train toolong
net = train(net,P,T);
% Y = sim(net,P); %Network Output

Tout=sim(net,Pt); %Get network output for the training domain

% test the result
for iterInd=1:length(Tt)
    [ToutPro(iterInd) ToutInd(iterInd)]=max(Tout(:,iterInd));
end
ErrPart=(ToutInd-Tt);
ErrRate=length(find(abs(ErrPart)>0))./length(Tt);


