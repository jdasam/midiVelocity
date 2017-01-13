function [Gx, midiVel, error, errorPerNoteResult, refVelCompare, maxIndexVector] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter)

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
    Gx = sheetMatrixMidi;

elseif strcmp(basicParameter.scale, 'erbt')
    sheetMatrixTotalCopy = sheetMatrixMidi(2:end,:);
    Gx = vertcat(sheetMatrixTotalCopy, sheetMatrixMidi(1,:));
end



if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')


    Bcopy = B;
    Xhat = (Bcopy.^basicParameter.spectrumMode * Gx .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode);
    
    betaDivVector = zeros(50);

%     Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
%     Bcopy = betaNormC(Bcopy,basicParameter.beta);
%     Bcopy(find(isnan(Bcopy)))=0;
% 

    for i = 1:50

        Gx = updateGwithTempoPartial(Gx, X, Bcopy, Xhat, basicParameter);
        Gx(find(isnan(Gx)))=0;

%         
%         Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
%         Bcopy = betaNormC(Bcopy,basicParameter.beta);
%         Bcopy(find(isnan(Bcopy)))=0;
        
        %         if basicParameter.rankMode == 1
%             Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))  ));
%         elseif basicParameter.rankMode == 2
%             Gx = updateGwithTempoPartial(Gx, X, Bcopy, Xhat, basicParameter);
%         end

        Xhat = (Bcopy.^basicParameter.spectrumMode * Gx.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode);

        %Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))  ));
        %Gx = Gx .* ( Bcopy'.^2 * (X.^2 .* (Xhat.^2 .^(basicParameter.beta-2) )) ./ (Bcopy.^2 * (Xhat.^2 .^ (basicParameter.beta-1))));
        %Gx = Gx .* sqrt ( (Bcopy'.^2 * (X .* (Xhat .^ -2))) ./ (Bcopy'.^2 * Xhat .^ 0));

        %Xhat = Bcopy * Gx;
        %betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta);
        %betaDivVector(i) = betaDivergence;
    end

elseif strcmp(basicParameter.scale, 'erbt')
    Bcopy= B;
    [Gx Bcopy] = erbtHarmclusNMF(X, Gx, false , 250,f,alen, basicParameter, false); 
    
    Gx = vertcat(Gx(end,:),Gx);
    Gx(end,:) = [];
end

% evaluate the result
midiVel = readmidi_java(MIDIFilename,true);
midiVel(:,7) = midiVel(:,6) + midiVel(:,7);
maxIndexVector = zeros(size(midiVel,1),1);


for i = 1:length(midiVel)
    
    basisIndex = midiVel(i,4) - basicParameter.minNote +2;
    
    index = onsetTime2frame(midiVel(i,6),basicParameter);
    offset = ceil( (midiVel(i,7) * basicParameter.sr) / basicParameter.nfft);
    
    indexEnd = index + basicParameter.searchRange;
    if indexEnd > size(Gx,2)
        indexEnd = size(Gx,2);
    end
    
    if indexEnd > offset
        indexEnd = offset;
    end
    

    [gainCalculated, maxIndex] = max(Gx(basisIndex, index:indexEnd));
    maxIndexVector(i) = maxIndex;
    
    coefA = fittingArray(1, basisIndex-1);
    coefB = fittingArray(2, basisIndex-1);

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


%plot(betaDivVector)






end