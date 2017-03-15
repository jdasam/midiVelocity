function [G, midiVel, error, errorPerNoteResult, refVelCompare, maxIndexVector, histogramData] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter)

if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
    X = audio2spectrogram(audioFilename, basicParameter);
    if strcmp(basicParameter.scale, 'midi')
    X = basicParameter.map_mx * X;
    end
elseif strcmp(basicParameter.scale, 'erbt')
    [X, f, alen] = audio2erbt(audioFilename, basicParameter);
end
fittingArray = basicParameter.fittingArray;

% Rewrite MIDI with fixed times
midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);
basicParameter.MIDI = midiRef;

sheetMatrixMidi = midi2MatrixOption(midiRef, size(X,2), basicParameter, false, basicParameter.weightOnAttack);


% Calculate Gx
if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
    G = sheetMatrixMidi;

elseif strcmp(basicParameter.scale, 'erbt')
    sheetMatrixTotalCopy = sheetMatrixMidi(2:end,:);
    G = vertcat(sheetMatrixTotalCopy, sheetMatrixMidi(1,:));
end

if basicParameter.BpartialUpdate
    harmBoolean = initializeWwithHarmonicConstraint(basicParameter); 
    harmBoolean(harmBoolean>0) = 1;
end



if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')

    Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
    
    if basicParameter.GpreUpdate
       for i = 1:basicParameter.GpreUpdate
           G = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
           G(find(isnan(G)))=0;
           Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
       end
        
    end
    

    for i = 1:50
        Bnew = B;
        Gnew = G;


        Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
        Gnew(find(isnan(Gnew)))=0;
        
        if i < basicParameter.updateBnumber
            if basicParameter.BpartialUpdate
                tempUpdate = (X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G') .* harmBoolean;
                tempUpdate(tempUpdate==0) = 1;
                Bnew = B .* tempUpdate;
                Bnew = betaNormC(Bnew,basicParameter.beta);
                Bnew(find(isnan(Bnew)))=0;
            else
                Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
                Bnew = betaNormC(Bnew,basicParameter.beta);
                Bnew(find(isnan(Bnew)))=0;
            end
        end

        B=Bnew;
        G=Gnew;

        Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

    end

elseif strcmp(basicParameter.scale, 'erbt')
    [G B] = erbtHarmclusNMF(X, G, B , 250,f,alen, basicParameter, false); 
    
    G = vertcat(G(end,:),G);
    G(end,:) = [];
end

if basicParameter.fittingArray(1,1)

    % evaluate the result
    midiVel = readmidi_java(MIDIFilename,true);
    midiVel(:,7) = midiVel(:,6) + midiVel(:,7);
    maxIndexVector = zeros(size(midiVel,1),1);
    gainFromVelVec = zeros(size(midiVel,1),1);
    gainCalculatedVec = zeros(size(midiVel,1),1);


    for i = 1:length(midiVel)
        
        basisIndex = midiVel(i,4) - basicParameter.minNote + 2;

        [gainCalculated, maxIndex] = findMaxGainByNote(midiVel(i,:), G, basicParameter);
        
        
        maxIndexVector(i) = maxIndex;

        coefA = fittingArray(1, basisIndex-1);
        coefB = fittingArray(2, basisIndex-1);

        logGainFromVel = exp(midiVel(i,5) * coefA + coefB);
        midiVel(i,5) = round(  ( log(gainCalculated) - coefB ) / coefA);
        gainFromVelVec(i) = logGainFromVel ^0.6;
        gainCalculatedVec(i) = gainCalculated ^0.6;
        %midiVel(i,5) = round(sqrt(max(Gx(pitch,index:index))) * 2.5);
        if midiVel(i,5) < 0
            midiVel(i,5) = 1;
        end
        if midiVel(i,5) > 127
            midiVel(i,5) = 127;
        end


    end
    histogramData = [];
    [histogramData.histData, histogramData.histMIDI, histogramData.f, histogramData.f2]= makeHistogram(MIDIFilename, G, basicParameter);

    % calculate error
    [error, errorPerNoteResult, refVelCompare] = calculateError(midiRef, midiVel, gainFromVelVec, gainCalculatedVec);


    %plot(betaDivVector)
end





end