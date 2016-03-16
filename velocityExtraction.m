function [midiVel, Gx, f, error, f2] = velocityExtraction(audioFilename, MIDIFilename, B, fittingArray, basicParameter)




[d2,sr] = audioread(audioFilename);
d2 = (d2(:,1) + d2(:,2))/2;


nfft = 2048;
window = 8192;
noverlap = window - basicParameter.hopSize;
[s2, f, t] = spectrogram (d2, window, noverlap);


% Rewrite MIDI with fixed times
midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);


% midiPitch - 19 ( ref scale's first note is 21, and this is second coloumn of B)
sheetMatrixMidi = zeros(basicParameter.maxNote-19, ceil(midiRef(length(midiRef), 7) * sr/basicParameter.hopSize));
sheetMatrixMidiRoll = zeros(basicParameter.maxNote-19, ceil(midiRef(length(midiRef), 7) * sr/basicParameter.hopSize));

for i = 1 : length(midiRef)
    notePitch = midiRef(i,4) - 19;
    onset = ceil( midiRef(i,6) * sr / basicParameter.hopSize) - floor(window/basicParameter.hopSize) + 1;
    offset = ceil( midiRef(i,7) * sr / basicParameter.hopSize) - floor(window/basicParameter.hopSize) + 1;

    sheetMatrixMidi(notePitch, onset:offset) = 0.1;
    
    if onset > 2
        sheetMatrixMidi(notePitch, onset-2:onset+2) = [0.3, 0.6, 1, 0.6, 0.3];
    else
        sheetMatrixMidi(notePitch, onset:onset+2) = [1, 0.6, 0.3];
    end
    
    sheetMatrixMidiRoll(notePitch, onset:offset) = 1;
    
end




for j = 1 :size(sheetMatrixMidi,2)
    if sum(sheetMatrixMidi(:,j)) == 0
        sheetMatrixMidi(1, j) = 1;
    end
end



imagesc(sheetMatrixMidi)

X = abs(s2);
%imagesc(log(X))
axis('xy')

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

%[B, Gx, cost] = beta_nmf_H(X, basicParameter.beta, 10, B, Gx);
%Xhat = Bcopy * Gx;  

Xhat = sqrt(Bcopy.^2 * Gx.^2);
%betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta)


Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))));

Bcopy = betaNormC(Bcopy,basicParameter.beta);
%Bcopy = normc(Bcopy);
Bcopy(find(isnan(Bcopy)))=0;


Gx(find(isnan(Gx)))=0;
Xhat = sqrt(Bcopy.^2 * Gx.^2);
%Xhat = Bcopy * Gx;  
%betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta)


betaDivVector = zeros(50);

for i = 1:50

    %Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
    Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))  ));
    Gx(find(isnan(Gx)))=0;
    %Bcopy = betaNormC(Bcopy,basicParameter.beta);
    %Bcopy(find(isnan(Bcopy)))=0;
    
    Xhat = sqrt(Bcopy.^2 * Gx.^2);
    %Xhat = Bcopy * Gx;  
    %betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta);
    %betaDivVector(i) = betaDivergence;
    

end




% evaluate the result
midiVel = midiRef;


gainData = zeros(length(midiVel),1);


for i = 1:length(midiVel)
    index = ceil( midiRef(i,6) * sr / basicParameter.hopSize) - floor(window/basicParameter.hopSize) + 1;
    if index < 3;
        index = 3;
    end
    
    
    pitch = midiVel(i,4) - 19;
    
    gainCalculated = max(Gx(pitch,index-2:index+2));
    gainData(i) = gainCalculated;
    
end
gainDB = 20 * log10(gainData + 0.000001);



histData = histogram(gainDB, ceil(max(gainDB)) - floor(min(gainDB)));
f = fit(linspace(floor(min(gainDB)),ceil(max(gainDB)), ceil(max(gainDB)) - floor(min(gainDB)))', histData.Values','gauss1');
histDataMIDI = histogram(midiRef(:,5), max(midiRef(:,5)) - min(midiRef(:,5)) + 1);
f2 = fit(linspace(min(midiRef(:,5)),max(midiRef(:,5)), histDataMIDI.NumBins)', histDataMIDI.Values','gauss1');


estimatedVelMean = 1.463 * f.b1 - 17.69;
estimatedVelRange = 2.574 * f.c1 - 0.949;

if ~isfield(basicParameter, 'targetVelMean'); basicParameter.targetVelMean = f2.b1; end
if ~isfield(basicParameter, 'targetVelRange'); basicParameter.targetVelRange = f2.c1; end

compA = (basicParameter.targetVelRange + 0.949) / 2.574 / f.c1;
compB = f.b1 - (basicParameter.targetVelMean + 17.69) / 1.463;


for i = 1:length(midiVel)
    index = ceil( midiRef(i,6) * sr / basicParameter.hopSize) - floor(window/basicParameter.hopSize) + 1;
    pitch = midiVel(i,4) - 19;
    
    if index > 2
        [gainCalculated microIndex] = max(Gx(pitch,index-2:index+2));
    else
        [gainCalculated microIndex] = max(Gx(pitch,index:index+2));
    end
    
    coefA = fittingArray(2, min(find(fittingArray(1,:)>=pitch-1))) * 20 / log(10) * compA;
    coefB = fittingArray(3, min(find(fittingArray(1,:)>=pitch-1))) * 20 / log(10) + compB;

    
    %coefA = fittingArraySMD(1,pitch-1);
    %coefB = fittingArraySMD(2,pitch-1);
    
    midiVel(i,5) = round( (log10(gainCalculated)*20 - coefB ) / coefA )  ; 
    midiVelNorm(i) = log(gainCalculated);
    %midiVel(i,5) = round(sqrt(max(Gx(pitch,index:index))) * 2.5);
    if midiVel(i,5) < 0
        midiVel(i,5) = 0;
    end
    if midiVel(i,5) > 127
        midiVel(i,5) = 127;
    end
    
    if microIndex ~= 3
        midiVel(i,6) = midiVel(i,6) + (microIndex - 3) * basicParameter.hopSize /sr;
    end
    
    
    
end

% calculate error
errorMatrix = zeros(length(midiVel),2);

for i = 1: length(midiVel)
    errorMatrix(i) = midiRef(i,4);
    errorMatrix(i,2) = abs(midiRef(i,5) - midiVel(i,5)) / midiRef(i,5);
end

error = sum(errorMatrix(:,2)) / length(errorMatrix); % error
errorSTD =std(errorMatrix(:,2));
%errorSTD = sqrt(sum((errorMatrix(:,2) - error).^2) / length(errorMatrix)); % error std


errorPerNote = zeros(2, max(errorMatrix(:,1)));


for i = 1 : length(errorMatrix)
    errorPerNote(1,errorMatrix(i,1)) = errorPerNote(1,errorMatrix(i,1)) + errorMatrix(i,2);
    errorPerNote(2,errorMatrix(i,1)) = errorPerNote(2,errorMatrix(i,1)) + 1;
end


result = errorPerNote(1,:) ./ errorPerNote(2,:);

if midiVel(10,7) > midiVel(10,6)
    midiVel(:,7) = midiRef(:,7) - midiVel(:,6);
end

OutputName = strcat(MIDIFilename, 'velocity.mid');
writemidi_seconds(midiVel,OutputName);

%hold off; plot(midiRef(:,5)); hold on; plot(midiVel(:,5), 'r'); hold off

%subplot(3,1,1); imagesc(db(X([1:200],r)+0.00001)); axis xy ; subplot(3,1,2); imagesc(Gx(:,r)); ; axis xy; subplot(3,1,3); imagesc(sheetMatrixMidiRoll(:,r)); ; axis xy
%hist(20*log10(gainData.^2+0.00001), 100)


%intensityRef = betaNormC(2 .^ (midiRef(:,5) * 0.04),2);
%intensityVel = betaNormC(gainData,2);

intensityRef = betaNormC(midiRef(:,5),2);
intensityVel = betaNormC(midiVel(:,5),2);




normalizedError = sum( abs( intensityRef - intensityVel) ./ intensityRef ) / length(intensityRef);
normalizedSTD = std(abs( intensityRef - intensityVel) ./ intensityRef );
error = [error; errorSTD; normalizedError; normalizedSTD];



%plot(betaDivVector)



end