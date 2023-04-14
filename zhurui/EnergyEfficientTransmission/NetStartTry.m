% %创建训练集
% p=[-1:0.05:1];
% t=sin(2*pi*p)+0.1*randn(size(p));
% %创建验证集
% v.P=[-0.975:0.05:0.975];
% v.T=[sin(2*pi*v.P)+0.1*randn(size(v.P))];
% %创建神经网络，用验证集帮助停止训练，ＦｅｅｄＦｏｒｗａｒｄｎｅｔ已经自带分隔训练集和验证集。
% net=newff(minmax(p),[20,10,1]);
% net.trainParam.show=25;
% net.trainParam.epochs=300;
% [net,tr]=train(net,p,t,[],[],v);
% %画出数据和网络的输出
% X=linspace(-1,1);
% Y=sim(net,X);
% plot(p,t,'k*',v.P,v.T,'ko',X,Y,'r-');
% legend('TrainingData','Testing Data','Network')

P = [0 1 2 3 4 5 6 7 8 9 10];%Training Patterns (domain values)
T = [0 1 2 3 4 3 2 1 2 3 4];%Training Targets (range values)
net = newff([0 10],[5 1],{'tansig' 'purelin'});
%Plot the original data points and the untrained output
Y = sim(net,P);
figure(1)
plot(P,T,P,Y,'o')
title('Data and Untrained Network Output')
%Train the network and plot the results
net.trainParam.goal=0.01; %0 is the default- too small!
net.trainParam.epochs = 50; %For our sample, don’t train toolong
net = train(net,P,T);
X = linspace(0,10); %New Domain Points
Y = sim(net,X); %Network Output
figure(2)
plot(P,T,'ko',X,Y)
%An alternative way to test training: postreg
figure(3)
Tout=sim(net,P); %Get network output for the training domain
[m,b,r]=postreg(T,Tout);