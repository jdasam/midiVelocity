function [errorCell, midiVelCell, refVelCompareCell] = velocityWithNeuralResult(B, basicParameter, dir, useNeuralNetResult)

    cd(dir);

    pieces = getFileListWithExtension('*.mp3');
    midiVelCell = {};
    errorList = zeros(6, length(pieces));
    refVelCompareCell = {};
    
    for i = 1:length(pieces)
        audioFilename = strcat(pieces{i}, '.mp3');
        MIDIFilename = strcat(pieces{i}, '.mid');
        txtFilename = strcat(pieces{i}, '_pedal.txt');
        csvFilename = strcat(pieces{i}, '.csv');
        
        nnResult = csvread(csvFilename);
        
        if useNeuralNetResult
            basicParameter.targetMedian = mean(nnResult);
            basicParameter.targetRange = std(nnResult)* sqrt(2);
        else
            basicParameter.targetMedian = 58.7;
            basicParameter.targetRange = 24;
%             nmat = readmidi_java(MIDIFilename);
%             basicParameter.targetMedian = mean(nmat(:,5));
%             basicParameter.targetRange = std(nmat(:,5)) * sqrt(2);
        end 

    %     basicParameter.fittingArray = fittingArrayCell{trainingGroupIndex, subSetIndex};

        [~, midiVel, error, errorPerNoteResult, refVelCompare]  =velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter, txtFilename);
        midiVelCell{i} = midiVel;
        errorCell(:,i) = error;
        refVelCompareCell{i} = refVelCompare;
        
        
    end



end