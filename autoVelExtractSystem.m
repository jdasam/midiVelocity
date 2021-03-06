function autoVelExtractSystem (basicParameter, subSet, resultName)
resultData = [];
resultData.title = {};
resultData.drParameter = [];
resultData.error = [];
resultData.velTruth = [];
resultData.errorByNote = {};
resultData.compareRefVel = {};
resultData.maxIndexVector = {};
resultData.histogramData = {};
resultName = strcat(resultName, '.mat');

if strcmp(basicParameter.scale, 'erbt')
    basicParameter.weightOnAttack = false;
    basicParameter.rankMode = 1;
    basicParameter.sr=22050;
    basicParameter.nfft = 512; 
    basicParameter.window =  512;
end


if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')

    cd(basicParameter.defaultFolderDir);
    Y = audio2spectrogram('pianoScale12Staccato2_440stretch.mp3', basicParameter);
    [basicParameter.minNote, basicParameter.maxNote, basicParameter.MIDI] = readScale(basicParameter);

    sheetMatrix = midi2MatrixOption(basicParameter.MIDI, length(Y), basicParameter);
    if basicParameter.Gfixed
        sheetMatrix = initializeSheetMatrixWithAmplitude(Y, sheetMatrix, basicParameter);
    end
    [~, B] = basisNMFoption(Y, sheetMatrix, basicParameter, basicParameter.iterationScale, basicParameter.Gfixed, false, false, 'scale');
    B = betaNormC(B,basicParameter.beta);

    if strcmp(basicParameter.basisSource, 'scale')
        for s = 1:length(subSet)
            dirSet = findFoldersInFolder(subSet{s});
            for i = 1:length(dirSet)
                dirEval = dirSet{i};
                dirTrain = dirSet;
                dirTrain(i) = [];

                basicParameter.fittingArray = trainFitFolder(B, basicParameter, dirTrain);
                resultData = velExtractionFolder(dirEval, B, basicParameter, resultData);
            end                                   
        end
        
    elseif strcmp(basicParameter.basisSource, 'data')
        for s = 1:length(subSet)
            Bscale = B;
            dirSet = findFoldersInFolder(subSet{s});
            for i = 1:length(dirSet)
                dirEval = dirSet{i};
                dirTrain = dirSet;
                dirTrain(i) = [];

                Bdata = trainBasisFromFolder(basicParameter, dirTrain, B);

                for j =1:size(Bdata,2)
                    if sum(Bdata(:,j)) == 0
                        Bdata(:,j) = B(:,j);
                    end
                end
                B = Bdata;

                basicParameter.fittingArray = trainFitFolder(B, basicParameter, dirTrain);
                resultData = velExtractionFolder(dirEval, B, basicParameter, resultData);
            end    
            B = Bscale;
        end
    end

elseif strcmp(basicParameter.scale, 'erbt')
    for s = 1:length(subSet)
    dirSet = findFoldersInFolder(subSet{s});
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
end



cd(basicParameter.resultFolderDir);

save(resultName, 'basicParameter', 'resultData', 'B');



end