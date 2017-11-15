function [B, basicParameter] = getDynamicRange(matAddress)


load(matAddress)


histData = zeros(15,4);
for i = 1:15
    histData(i,1) = resultData.histogramData{1,i}.f.b1;
    histData(i,2) = resultData.histogramData{1,i}.f.c1;
    histData(i,3) = resultData.histogramData{1,i}.f2.b1;
    histData(i,4) = resultData.histogramData{1,i}.f2.c1;
    
end
[lassoAll, stats] = lasso(histData(:,1), histData(:,3), 'CV', 5);
basicParameter.dynMed = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];
[lassoAll, stats] = lasso(histData(:,2), histData(:,4), 'CV', 5);
basicParameter.dynRan = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];


end