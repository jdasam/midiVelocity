function autoOnsetExtractSystem (basicParameter, subSet, resultName)
resultData = [];
resultData.title = {};
resultData.drParameter = [];
resultData.error = [];
resultData.velTruth = [];
resultData.errorByNote = {};
resultData.compareRefVel = {};
resultData.maxIndexVector = {};
resultData.histogramData = {};
% resultData.velocityGainMatchingData = {};
resultName = strcat(resultName, '.mat');

Bcell = {};
fittingArrayCell = {};
velocityGainMatchingCell={};
for s = 1:length(subSet)
    dirSet = findFoldersInFolder(subSet{s});
    for i = 1:length(dirSet)
        dirEval = dirSet{i};
        dirTrain = dirSet;
        dirTrain(i) = [];

        [basicParameter.fittingArray, velocityGainMatchingCell{s,i}] = trainFitFolder(B, basicParameter, dirTrain);
        resultData = velExtractionFolder(dirEval, B, basicParameter, resultData);
        fittingArrayCell{s,i} = basicParameter.fittingArray;
    end                                   
end



cd(basicParameter.resultFolderDir);

if basicParameter.saveOnsetCluster
    save(resultName, 'basicParameter', 'resultData', 'B', 'Bcell', 'fittingArrayCell', 'velocityGainMatchingCell', '-v7.3');

else
    save(resultName, 'basicParameter', 'resultData', 'B', 'Bcell', 'fittingArrayCell');
end


end