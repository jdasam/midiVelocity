function autoVelExtractSystem (basicParameter, dirSet, resultName)
resultData = [];
resultData.title = {};
resultData.drParameter = [];
resultData.error = [];
resultData.velTruth = [];
resultData.errorByNote = {};
resultData.compareRefVel = {};
resultData.maxIndexVector = {};
resultName = strcat(resultName, '.mat');  


cd(basicParameter.defaultFolderDir);
Y = audio2spectrogram('pianoScale12Staccato2_440stretch.mp3', basicParameter);
[basicParameter.minNote, basicParameter.maxNote, basicParameter.MIDI] = readScale(basicParameter);

sheetMatrix = midi2MatrixOption(basicParameter.MIDI, length(Y), basicParameter);
if basicParameter.Gfixed
    sheetMatrix = initializeSheetMatrixWithAmplitude(Y, sheetMatrix, basicParameter);
end
[~, B] = basisNMFoption(Y, sheetMatrix, basicParameter, basicParameter.iteration, basicParameter.Gfixed);
B = betaNormC(B,basicParameter.beta);

if strcmp(basicParameter.basisSource, 'scale')
    for i = 1:length(dirSet)
        dirEval = dirSet{i};
        dirTrain = dirSet;
        dirTrain(i) = [];

        basicParameter.fittingArray = trainFitFolder(B, basicParameter, dirTrain);
        resultData = velExtractionFolder(dirEval, B, basicParameter, resultData);
    end


elseif strcmp(basicParameter.basisSource, 'data')
    for i = 1:length(dirSet)
        dirEval = dirSet{i};
        dirTrain = dirSet;
        dirTrain(i) = [];

        Bdata = trainBasisFromFolder(basicParameter, dirTrain);
        
        for j =1:size(Bdata,2)
            if sum(Bdata(:,j)) == 0
                Bdata(:,j) = B(:,j);
            end
        end
        B = Bdata;
        
        basicParameter.fittingArray = trainFitFolder(B, basicParameter, dirTrain);
        resultData = velExtractionFolder(dirEval, B, basicParameter, resultData);
    end               
end

cd(basicParameter.resultFolderDir);

save(resultName, 'basicParameter', 'resultData', 'B');


end