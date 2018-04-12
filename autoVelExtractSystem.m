function autoVelExtractSystem (basicParameter, subSet, resultName, scaleB)
resultData = [];
resultData.title = {};
resultData.drParameter = [];
resultData.error = [];
resultData.velTruth = [];
resultData.errorByNote = {};
resultData.compareRefVel = {};
resultData.maxIndexVector = {};
resultData.histogramData = {};

semiAlignedResultData = resultData;
% resultData.velocityGainMatchingData = {};
resultName = strcat(resultName, '.mat');

Bcell = {};
fittingArrayCell = {};
velocityGainMatchingCell={};

semiAlignedParameter = basicParameter;
semiAlignedParameter.midiExtension = '_aligned.mid'; 
semiAlignedParameter.usePseudoAligned = true;

if strcmp(basicParameter.scale, 'erbt')
    basicParameter.weightOnAttack = false;
    basicParameter.rankMode = 1;
    basicParameter.sr=22050;
    basicParameter.nfft = 512; 
    basicParameter.window =  512;
end

if length(fieldnames(basicParameter)) > length(fieldnames(basicParameterInitialize()))
    warning('There is an extra field in basicParameter')
end

if strcmp(basicParameter.scale, 'stft') || strcmp(basicParameter.scale, 'midi')
    if strcmp(basicParameter.basisSource, 'scale') || basicParameter.useInitialB
        if nargin == 4
            B = scaleB;
        else
            B= learnBasisFromScale(basicParameter);
        end
    else
        B = initializeWwithHarmonicConstraint(basicParameter);
        if basicParameter.harmConstrain == false || basicParameter.softConstraint
            B = rand(size(B));
        end
    end

    if strcmp(basicParameter.basisSource, 'scale') || strcmp(basicParameter.basisSource, 'rand')
        for s = 1:length(subSet)
            dirSet = findFoldersInFolder(subSet{s});
            for i = 1:length(dirSet)
                dirEval = dirSet{i};
                dirTrain = dirSet;
                dirTrain(i) = [];

                [basicParameter.fittingArray, velocityGainMatchingCell{s,i}] = trainFitFolder(B, basicParameter, dirTrain);
                resultData = velExtractionFolder(dirEval, B, basicParameter, resultData);
                semiAlignedParameter.fittingArray = basicParameter.fittingArray;
                semiAlignedResultData = velExtractionFolder(dirEval, B, semiAlignedParameter, semiAlignedResultData);
                fittingArrayCell{s,i} = basicParameter.fittingArray;
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

                [basicParameter.fittingArray, velocityGainMatchingCell{s,i}] = trainFitFolder(B, basicParameter, dirTrain);
                resultData = velExtractionFolder(dirEval, B, basicParameter, resultData);
                semiAlignedParameter.fittingArray = basicParameter.fittingArray;
                semiAlignedResultData = velExtractionFolder(dirEval, B, semiAlignedParameter, semiAlignedResultData);
                Bcell{s,i} = B;
                fittingArrayCell{s,i} = basicParameter.fittingArray;
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

% if basicParameter.saveOnsetCluster
    save(resultName, 'basicParameter', 'resultData', 'semiAlignedResultData', 'B', 'Bcell', 'fittingArrayCell', 'velocityGainMatchingCell', '-v7.3');

% else
%     save(resultName, 'basicParameter', 'resultData', 'B', 'Bcell', 'fittingArrayCell');
% end


end


function B= learnBasisFromScale(basicParameter)
    cd(basicParameter.defaultFolderDir);
    Y = audio2spectrogram('pianoScale12Staccato2_440stretch.mp3', basicParameter);
    [basicParameter.minNote, basicParameter.maxNote, basicParameter.MIDI] = readScale(basicParameter);

    sheetMatrix = midi2MatrixOption(basicParameter.MIDI, length(Y), basicParameter);
    if basicParameter.Gfixed
        sheetMatrix = initializeSheetMatrixWithAmplitude(Y, sheetMatrix, basicParameter);
    end
    [~, B] = basisNMFoption(Y, sheetMatrix, basicParameter, basicParameter.iterationScale, basicParameter.Gfixed, false, false, 'scale');
    
    if basicParameter.beta3 ==0 
        B = betaNormC(B,basicParameter.beta);
    end

end