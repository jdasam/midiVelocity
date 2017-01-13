function autoVelExtractSystem (basicParameter, dirSet)
resultData = [];
resultData.title = {};
resultData.drParameter = [];
resultData.error = [];
resultData.velTruth = [];
resultData.errorByNote = {};
resultData.compareRefVel = {};

if strcmp(basicParameter.basisSource, 'scale')
    Y = audio2spectrogram('pianoScale12Staccato2_440stretch.mp3', basicParameter);
    [basicParameter.minNote, basicParameter.maxNote, basicParameter.MIDI] = readScale(basicParameter);

    sheetMatrix = midi2MatrixOption(basicParameter.MIDI, length(Y), basicParameter);
    if basicParameter.Gfixed
        sheetMatrix = initializeSheetMatrixWithAmplitude(Y, sheetMatrix, basicParameter);
    end
    [~, B] = basisNMFoption(Y, sheetMatrix, basicParameter, basicParameter.iteration, basicParameter.Gfixed);
    B = betaNormC(B,basicParameter.beta);

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

        B = trainBasisFromFolder(basicParameter, dirTrain);
        basicParameter.fittingArray = trainFitFolder(B, basicParameter, dirTrain);
        resultData = velExtractionFolder(dirEval, B, basicParameter, resultData);
    end               
end


    
    
    
    

end