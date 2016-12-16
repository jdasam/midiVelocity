function [Gx, midiVel, error, errorPerNoteResult, refVelCompare] = velocityExtractionModifiedFit(audioFilename, MIDIFilename, B, basicParameter)




[d2,sr] = audioread(audioFilename);
d2 = (d2(:,1) + d2(:,2))/2;


nfft = basicParameter.nfft;
window = basicParameter.window;
noverlap = window - basicParameter.nfft;
[s2, f, t] = spectrogram (d2, window, noverlap);


% Rewrite MIDI with fixed times
midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);


% midiPitch - 19 ( ref scale's first note is 21, and this is second coloumn of B)
sheetMatrixMidi = zeros(basicParameter.maxNote-19, ceil(midiRef(length(midiRef), 7) * sr/basicParameter.nfft));
sheetMatrixMidiRoll = zeros(basicParameter.maxNote-19, ceil(midiRef(length(midiRef), 7) * sr/basicParameter.nfft));

for i = 1 : length(midiRef)
    notePitch = midiRef(i,4) - 19;
    sampleIndex = midiRef(i,6) * sr;
    if sampleIndex < window/2
        onset = 1;
    else
        onset = ceil( ( sampleIndex - window /2 )/ basicParameter.nfft) + 1;
    end
    offset = ceil( midiRef(i,7) * sr / basicParameter.nfft) + 1;
    sheetMatrixMidi(notePitch, onset:offset) = 1;
    
    if onset > 2
        sheetMatrixMidi(notePitch, onset-2:onset+2) = 10 *[0.3, 0.6, 1, 0.6, 0.3];
    else
        sheetMatrixMidi(notePitch, onset:onset+2) = 10 * [1, 0.6, 0.3];
    end
    
    sheetMatrixMidiRoll(notePitch, onset:offset) = 1;
    
end




for j = 1 :size(sheetMatrixMidi,2)
    if sum(sheetMatrixMidi(:,j)) == 0
        sheetMatrixMidi(1, j) = 1;
    end
end

X = abs(s2);



if size(sheetMatrixMidi,2) < size(X,2)
    X(:, size(sheetMatrixMidi,2) + 1 : size(X,2) ) = [];
elseif size(sheetMatrixMidi,2) > size(X,2)
    dummyMatrix = ones(size(X,1), size(sheetMatrixMidi,2) - size(X,2)) * 0.00000001;
    X = horzcat(X,dummyMatrix);
end

%X(501:4097,:) = ones(3597, size(X,2)) * 0.00000000001;



% Calculate Gx
Gx = sheetMatrixMidi;


Bcopy = B;
Bcopy = betaNormC(Bcopy,basicParameter.beta);

%[B, Gx, cost] = beta_nmf_H(X, basicParameter.beta, 10, B, Gx);
%Xhat = Bcopy * Gx;  

Xhat = Bcopy * Gx;
%betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta)


Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
%Gx = Gx .* ( Bcopy'.^2 * (X.^2 .* ((Xhat.^2) .^(basicParameter.beta-2) )) ./ (Bcopy.^2 * ((Xhat.^2) .^ (basicParameter.beta-1))));
Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))));

%Gx = Gx .* sqrt( ( Bcopy'.^2 * (X .* (Xhat .^((basicParameter.beta-2)*2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1)))) );




%Gx = Gx .* sqrt ( ( (Bcopy' .^0 * Xhat) ./ (Bcopy' * Xhat .^ 0) ) .* (Bcopy' * (X .* (Xhat .^ -1))));
%Gx = Gx .* sqrt ( (Bcopy'.^2 * (X .* (Xhat .^ -2))) ./ (Bcopy'.^2 * Xhat .^ 0));




Bcopy = betaNormC(Bcopy,basicParameter.beta);
%Bcopy = normc(Bcopy);
Bcopy(find(isnan(Bcopy)))=0;


Gx(find(isnan(Gx)))=0;
Xhat = Bcopy * Gx;
%Xhat = Bcopy * Gx;  
%betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta)


betaDivVector = zeros(50);

for i = 1:50

    %Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
    Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))  ));
    %Gx = Gx .* ( Bcopy'.^2 * (X.^2 .* (Xhat.^2 .^(basicParameter.beta-2) )) ./ (Bcopy.^2 * (Xhat.^2 .^ (basicParameter.beta-1))));
    %Gx = Gx .* sqrt ( (Bcopy'.^2 * (X .* (Xhat .^ -2))) ./ (Bcopy'.^2 * Xhat .^ 0));



    Gx(find(isnan(Gx)))=0;
    %Bcopy = betaNormC(Bcopy,basicParameter.beta);
    %Bcopy(find(isnan(Bcopy)))=0;
    
    Xhat = Bcopy * Gx;
    %Xhat = Bcopy * Gx;  
    %betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta);
    %betaDivVector(i) = betaDivergence;
    

end



% evaluate the result
fittingArray = basicParameter.fittingArray;
midiVel = readmidi_java(MIDIFilename,true);

gainData = zeros(length(midiVel),1);
testVector = zeros(length(midiVel),1);


for i = 1:length(midiVel)
    
    pitch = midiVel(i,4);
    sampleIndex = midiVel(i,6) * sr;
    if sampleIndex < window/2
        index = 1;
    else
        index = ceil( ( midiVel(i,6) * basicParameter.sr - basicParameter.window /2 )/ basicParameter.nfft);
    end
    
        
    %gainCalculated = max(Gx(2 + (pitch - basicParameter.minNote) * 2,index:index+3));
    gainCalculated = max(Gx(2 + (pitch - basicParameter.minNote),index:index+3));

    gainData(i) = gainCalculated;
    
    
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





end