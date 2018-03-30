function [errorList, midiVelCell, refVelCompareCell] = velocityWithNeuralResult(B, basicParameter, dir, testMode)

    cd(dir);

    pieces = getFileListWithExtension('*.mp3');
    midiVelCell = {};
    errorList = zeros(6, length(pieces));
    refVelCompareCell = {};
    basicParameter.fittingArray(1,1) = 1;
    for i = 1:length(pieces)
        audioFilename = strcat(pieces{i}, '.mp3');
        MIDIFilename = strcat(pieces{i}, '.mid');
        txtFilename = strcat(pieces{i}, '_pedal.txt');
        csvFilename = strcat(pieces{i}, '.csv');
        
        nnResult = csvread(csvFilename);
        
        if strcmp(testMode, 'nn')
            basicParameter.targetMedian = mean(nnResult);
            basicParameter.targetRange = std(nnResult)* sqrt(2);
        elseif strcmp(testMode, 'gt')
            nmat = readmidi_java(MIDIFilename);
            basicParameter.targetMedian = mean(nmat(:,5));
            basicParameter.targetRange = std(nmat(:,5)) * sqrt(2);
        else
            basicParameter.targetMedian = 57.87;
            basicParameter.targetRange = 16.25*sqrt(2);

        end 

    %     basicParameter.fittingArray = fittingArrayCell{trainingGroupIndex, subSetIndex};

        [~, midiVel, error, errorPerNoteResult, refVelCompare]  =velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter, txtFilename);
        midiVelCell{i} = midiVel;
        errorList(:,i) = error;
        refVelCompareCell{i} = refVelCompare;
        
        
    end



end