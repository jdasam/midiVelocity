function errorRoll = plotErrorPianoRoll(midi, velEstimated, basicParameter)

    if midi(end,7) < midi(end,6)
        midi(:,7) = midi(:,6) + midi(:,7);
    end
    velError = abs(midi(:,5) - velEstimated);
    matLength = ceil(midi(end,7) * basicParameter.sr / basicParameter.nfft);
    
    basicParameter.rankMode = 1;
    errorRoll = midi2MatrixOption(midi,matLength, basicParameter);
    
    for i=1:size(midi, 1)
        
        timeIndex = onsetTime2frame(midi(i,6), basicParameter);
        pitchIndex = midi(i,4) - basicParameter.minNote +2;
        
        errorRoll(pitchIndex, timeIndex) = velError(i)+2;
        
    end

    
%     imagesc(errorRoll)
    imagesc(errorRoll.^0.3)
    axis 'xy'
end