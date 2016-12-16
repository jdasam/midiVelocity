function [Gx, midiVel, error, errorPerNoteResult, refVelCompare] = velocityExtractionAnSpowerTemporal(audioFilename, MIDIFilename, B, basicParameter)

[d2,sr] = audioread(audioFilename);
d2 = (d2(:,1) + d2(:,2))/2;


nfft = basicParameter.nfft;
window = basicParameter.window;
noverlap = window - basicParameter.nfft;
fittingArray = basicParameter.fittingArray;
[s2, f, t] = spectrogram (d2, window, noverlap);
X = abs(s2);

% Rewrite MIDI with fixed times
midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);


sheetMatrixMidi = midi2Matrix(midiRef, length(X), basicParameter);

% midiPitch - 19 ( ref scale's first note is 21, and this is second coloumn of B)
% sheetMatrixMidi = zeros(basicParameter.maxNote-basicParameter.minNote+2, ceil(midiRef(length(midiRef), 7) * sr/basicParameter.hopSize));
%sheetMatrixMidiRoll = zeros(basicParameter.maxNote-basicParameter.minNote+2, ceil(midiRef(length(midiRef), 7) * sr/basicParameter.hopSize));





% for i = 1 : length(midiRef)
%     notePitch = midiRef(i,4) - basicParameter.minNote+2;
%     sampleIndex = midiRef(i,6) * sr;
%     if sampleIndex < window/2
%         onset = 1;
%     else
%         onset = ceil( ( sampleIndex - window /2 )/ basicParameter.hopSize);
%     end
%     offset = ceil( midiRef(i,7) * sr / basicParameter.hopSize) + 1;
%     sheetMatrixMidi(notePitch, onset:offset) = 1;
%     
%     if onset > 2
%         sheetMatrixMidi(notePitch, onset-2:onset+2) = 10 *[0.3, 0.6, 1, 0.6, 0.3];
%     else
%         sheetMatrixMidi(notePitch, onset:onset+2) = 10 * [1, 0.6, 0.3];
%     end
%     
%     %sheetMatrixMidiRoll(notePitch, onset:offset) = 1;
%     
% end


% for j = 1 :size(sheetMatrixMidi,2)
%     if sum(sheetMatrixMidi(:,j)) == 0
%         sheetMatrixMidi(1, j) = 1;
%     end
% end


if size(sheetMatrixMidi,2) < size(X,2)
    X(:, size(sheetMatrixMidi,2) + 1 : size(X,2) ) = [];
elseif size(sheetMatrixMidi,2) > size(X,2)
    dummyMatrix = ones(size(X,1), size(sheetMatrixMidi,2) - size(X,2)) * 0.00000001;
    X = horzcat(X,dummyMatrix);
end



% Calculate Gx
GxBasic = sheetMatrixMidi(basicParameter.minNote-1:size(sheetMatrixMidi,1),:);
Gx=zeros(size(GxBasic));

Bcopy = zeros(size(B));
for i=1:size(B,2)
    if mod(i,2) == 1
       Bcopy(:,(i+1)/2) = B(:,i);
       Gx((i+1)/2,:) = GxBasic(i,:);
    else
       Bcopy(:,(size(B,2)-1)/2+1+i/2) = B(:,i);
       Gx((size(B,2)-1)/2+1+i/2,:) = GxBasic(i,:);
    end
    
end

Bcopy = betaNormC(Bcopy,basicParameter.beta);



%[B, Gx, cost] = beta_nmf_H(X, basicParameter.beta, 10, B, Gx);
%Xhat = Bcopy * Gx;  

Xhat = sqrt(Bcopy.^2 * Gx.^2);
%betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta)


Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
%Gx = Gx .* ( Bcopy'.^2 * (X.^2 .* ((Xhat.^2) .^(basicParameter.beta-2) )) ./ (Bcopy.^2 * ((Xhat.^2) .^ (basicParameter.beta-1))));
Gx = updateGwithTempoPartial(Gx, X, Bcopy, Xhat, basicParameter.beta, basicParameter.alpha);

%Gx = Gx .* sqrt( ( Bcopy'.^2 * (X .* (Xhat .^((basicParameter.beta-2)*2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1)))) );




%Gx = Gx .* sqrt ( ( (Bcopy' .^0 * Xhat) ./ (Bcopy' * Xhat .^ 0) ) .* (Bcopy' * (X .* (Xhat .^ -1))));
%Gx = Gx .* sqrt ( (Bcopy'.^2 * (X .* (Xhat .^ -2))) ./ (Bcopy'.^2 * Xhat .^ 0));




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
    Gx = updateGwithTempoPartial(Gx, X, Bcopy, Xhat, basicParameter.beta, basicParameter.alpha);
    %Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))  ));
    %Gx = Gx .* ( Bcopy'.^2 * (X.^2 .* (Xhat.^2 .^(basicParameter.beta-2) )) ./ (Bcopy.^2 * (Xhat.^2 .^ (basicParameter.beta-1))));
    %Gx = Gx .* sqrt ( (Bcopy'.^2 * (X .* (Xhat .^ -2))) ./ (Bcopy'.^2 * Xhat .^ 0));



    Gx(find(isnan(Gx)))=0;
    %Bcopy = betaNormC(Bcopy,basicParameter.beta);
    %Bcopy(find(isnan(Bcopy)))=0;
    
    Xhat = sqrt(Bcopy.^2 * Gx.^2);
    %Xhat = Bcopy * Gx;  
    %betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta);
    %betaDivVector(i) = betaDivergence;
    

end



% evaluate the result
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
    gainCalculated = max(Gx(90 + (pitch - basicParameter.minNote),index:index+3));

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
% gainDB = 20 * log10(gainData + 0.000001);
% 
% 
% 
% histData = histogram(gainDB, ceil(max(gainDB)) - floor(min(gainDB)));
% f = fit(linspace(floor(min(gainDB)),ceil(max(gainDB)), ceil(max(gainDB)) - floor(min(gainDB)))', histData.Values','gauss1');
% histDataMIDI = histogram(midiRef(:,5), max(midiRef(:,5)) - min(midiRef(:,5)) + 1);
% f2 = fit(linspace(min(midiRef(:,5)),max(midiRef(:,5)), histDataMIDI.NumBins)', histDataMIDI.Values','gauss1');
% 
% 
% estimatedVelMean = 2.0163 * f.b1 - 56.3573;
% estimatedVelRange = 2.2909 * f.c1 + 2.8077;
% 
% if ~isfield(basicParameter, 'targetVelMean'); basicParameter.targetVelMean = f2.b1; end
% if ~isfield(basicParameter, 'targetVelRange'); basicParameter.targetVelRange = f2.c1; end
% 
% targetGainMean =  (basicParameter.targetVelMean + 56.3573) / 2.0163;
% targetGainRange = (basicParameter.targetVelRange - 2.8077) / 2.2909;
% compA = targetGainRange/ f.c1;
% compB = f.b1 - targetGainMean;




% if midiVel(10,7) > midiVel(10,6) %if offset is still absolute time, not duration.
%     midiVel(:,7) = midiRef(:,7) - midiVel(:,6);
% end
% 
% midiVel(midiVel(:,7) < 0, 7) = 0.04;
% 

% calculate error
[error, errorPerNoteResult, refVelCompare] = calculateError(midiRef, midiVel);








end