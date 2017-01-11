plot(U(:,28))
hold on
plot(U(:,40))
%plot(X(:,30))
hold off

%%
plot(X(:,260))
hold on
plot(Y(:,260))
%plot(X(:,30))
hold off


%%

targetPitch = 20;
plot(log(B(1:1000,targetPitch)))
hold on
plot(log(Bsmd(1:1000,targetPitch)))
%plot(X(:,30))
plot(log(B443equal(1:1000,targetPitch)))
hold off

