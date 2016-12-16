targetPitch = 50;
dataSize = max(find(xdataSMD(:,targetPitch)));

[BlassoAll, stats] = lasso(xdataSMD(1:max(find(xdataSMD(:,targetPitch))),targetPitch), log(ydataSMD(1:max(find(xdataSMD(:,targetPitch))),targetPitch)), 'CV', 5);
%lassoPlot(BlassoAll,stats,'PlotType','CV')


f = @(x) stats.Intercept(stats.IndexMinMSE) + BlassoAll(stats.IndexMinMSE) * x;
[BlassoAll(stats.IndexMinMSE) stats.Intercept(stats.IndexMinMSE)]
%
hold off
scatter(xdataSMD(1:dataSize,targetPitch), log(ydataSMD(1:dataSize,targetPitch)))
hold on
plot(f(1:128))