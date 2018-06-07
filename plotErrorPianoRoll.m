function errorRoll = plotErrorPianoRoll(midi, velEstimated, basicParameter, softPedal)

    if nargin < 4
        softPedal = false; 
    end
    basicParameter.nfft = 441;

    if midi(end,7) < midi(end,6)
        midi(:,7) = midi(:,6) + midi(:,7);
    end
    velError = abs(midi(:,5) - velEstimated);
    matLength = ceil(midi(end,7) * basicParameter.sr / basicParameter.nfft);
    
    basicParameter.rankMode = 1;
    errorRoll = midi2MatrixOption(midi,matLength, basicParameter, false,false, true);
    
    
    if softPedal
        pedalDouble = readPedalCsv(softPedal);
        threshold = basicParameter.pedalThreshold;
        for i=1:size(midi, 1)
            onset=midi(i,6);
            offsetIndex = onsetTime2frame(midi(i,7), basicParameter);
            timeIndex = onsetTime2frame(midi(i,6), basicParameter);
            pitchIndex = midi(i,4) - basicParameter.minNote +2;
            
            lastIndex = max(find(pedalDouble(:,1) < onset));
            pedalOn = pedalDouble(lastIndex, 2) > threshold;
            if pedalOn
                errorRoll(pitchIndex, timeIndex:offsetIndex) = 200;
            end
        end
        
        imagesc(errorRoll)
%     imagesc(errorRoll.^0.8)
        axis 'xy'
        return
    end
    
    for i=1:size(midi, 1)
        
        timeIndex = onsetTime2frame(midi(i,6), basicParameter);
        pitchIndex = midi(i,4) - basicParameter.minNote +2;
        
%         errorRoll(pitchIndex, timeIndex) = velError(i)+2;
        errorRoll(pitchIndex, timeIndex) = velError(i)+errorRoll(pitchIndex, timeIndex);

        
    end

    
    imagesc(errorRoll)
%     imagesc(errorRoll.^0.8)
    axis 'xy'
end