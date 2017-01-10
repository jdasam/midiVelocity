function [Gx, midiVel, error, errorPerNoteResult, refVelCompare] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter)

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

sheetMatrixMidi = midi2MatrixOption(midiRef, size(X,2), basicParameter, false, basicParameter.weightOnAttack);


% Calculate Gx
if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
    Gx = sheetMatrixMidi(basicParameter.minNote-1:size(sheetMatrixMidi,1),:);

elseif strcmp(basicParameter.scale, 'erbt')
    sheetMatrixTotalCopy = sheetMatrixMidi(basicParameter.minNote:end,:);
    Gx = vertcat(sheetMatrixTotalCopy, sheetMatrixMidi(basicParameter.minNote-1,:));
end



if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')


    Bcopy = B;
    if strcmp(basicParameter.spectrumMode, 'linear')
       Xhat = Bcopy * Gx;
    elseif strcmp(basicParameter.spectrumMode, 'power')
       Xhat = sqrt(Bcopy.^2 * Gx.^2);
    end

    betaDivVector = zeros(50);

    Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
    Bcopy = betaNormC(Bcopy,basicParameter.beta);
    Bcopy(find(isnan(Bcopy)))=0;


    for i = 1:50

        %Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
        if basicParameter.rankMode == 1
            Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))  ));
        elseif basicParameter.rankMode == 2
            Gx = updateGwithTempoPartial(Gx, X, Bcopy, Xhat, basicParameter.beta, basicParameter.alpha);
        end
        Gx(find(isnan(Gx)))=0;


        %Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))  ));
        %Gx = Gx .* ( Bcopy'.^2 * (X.^2 .* (Xhat.^2 .^(basicParameter.beta-2) )) ./ (Bcopy.^2 * (Xhat.^2 .^ (basicParameter.beta-1))));
        %Gx = Gx .* sqrt ( (Bcopy'.^2 * (X .* (Xhat .^ -2))) ./ (Bcopy'.^2 * Xhat .^ 0));
        %Bcopy = betaNormC(Bcopy,basicParameter.beta);
        %Bcopy(find(isnan(Bcopy)))=0;

        if strcmp(basicParameter.spectrumMode, 'linear')
           Xhat = Bcopy * Gx;
        elseif strcmp(basicParameter.spectrumMode, 'power')
           Xhat = sqrt(Bcopy.^2 * Gx.^2);
        end
        %Xhat = Bcopy * Gx;
        %betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta);
        %betaDivVector(i) = betaDivergence;
    end

elseif strcmp(basicParameter.scale, 'erbt')
    Bcopy= B;
    [Gx Bcopy] = erbtHarmclusNMF(X, Gx, Bcopy, 250,f,alen, basicParameter, true); 
    
    Gx = vercat(Gx(end,:),Gx);
    Gx(end,:) = [];
end

% evaluate the result
midiVel = readmidi_java(MIDIFilename,true);



for i = 1:length(midiVel)
    
    pitch = midiVel(i,4);
    
    index = onsetTime2frame(midiVel(i,6),basicParameter);

    
    if basicParameter.rankMode == 1
        gainCalculated = max(Gx(2 + pitch - basicParameter.minNote, index:index+basicParameter.searchRange));
    elseif basicParameter.rankMode == 2
        gainCalculated = max(Gx(2 + (pitch - basicParameter.minNote) * 2,index:index+basicParameter.searchRange));
    end
    
    
    coefA = fittingArray(1, pitch-basicParameter.minNote+1);
    coefB = fittingArray(2, pitch-basicParameter.minNote+1);

    midiVel(i,5) = round(  ( log(gainCalculated) - coefB ) / coefA) ; 
    midiVelNorm(i) = log(gainCalculated);
    %midiVel(i,5) = round(sqrt(max(Gx(pitch,index:index))) * 2.5);
    if midiVel(i,5) < 0
        midiVel(i,5) = 1;
    end
    if midiVel(i,5) > 127
        midiVel(i,5) = 127;
    end
    
    
end


% calculate error
[error, errorPerNoteResult, refVelCompare] = calculateError(midiRef, midiVel);


plot(betaDivVector)






end