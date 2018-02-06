function [basicParameterOut] = getDynamicRange(matAddress, basicParameter, indexA, indexB)

basicParameterOut = basicParameter;
load(matAddress)


histData = zeros(size(resultData.histogramData, 2),4);
for i = indexA:indexB
    histData(i,1) = resultData.histogramData{1,i}.f.b1;
    histData(i,2) = resultData.histogramData{1,i}.f.c1;
    histData(i,3) = resultData.histogramData{1,i}.f2.b1;
    histData(i,4) = resultData.histogramData{1,i}.f2.c1;
    
end
[lassoAll, stats] = lasso(histData(:,1), histData(:,3), 'CV', 5);
basicParameterOut.dynMed = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];
[lassoAll, stats] = lasso(histData(:,2), histData(:,4), 'CV', 5);
basicParameterOut.dynRan = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];


end