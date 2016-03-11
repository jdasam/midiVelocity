[d1,sr] = audioread('pianoVelScale.mp3');

d1 = d1(:,1);
    

nfft = 2048;
window = nfft * 4;
noverlap = window - nfft;

[s, f, t] = spectrogram (d1, window, noverlap);


Y = abs(s);


%%

MIDIFilename = 'newScale.mid';


% Rewrite MIDI with fixed times
nmat = readmidi_java(MIDIFilename,true);
nmat(:,7) = nmat(:,6) + nmat(:,7);
noteArray = unique(nmat(:,4));


%%



sheetMatrix = zeros(max(noteArray) , floor(nmat(length(nmat), 7) * 44100/nfft));

ADSR = ones(1, round(2.4 * 44100/nfft));
for i = 1:length(ADSR)
    ADSR(i) = ADSR(i) * (length(ADSR)-i);
end



for i = 1 : length(nmat)
    notePitch = nmat(i,4);
    onset = floor( nmat(i,6) * 44100 / nfft);
    offset = floor( nmat(i,7) * 44100 / nfft);
    sheetMatrix (notePitch, onset+1:offset+1) = 1;
    %sheetMatrix (notePitch, onset+1:onset+4) = 2 ^ (nmat(i,5)/11);
end

for j = 1 :size(sheetMatrix,2)
    if sum(sheetMatrix(:,j)) == 0
        sheetMatrix(min(noteArray)-1, j) = 1;
    end
end


if size(Y,2) > size(sheetMatrix,2)

    Y(:, length(sheetMatrix) + 1 : length(Y) ) = [];
    Y(Y==0) = 0.000001;
end

%%
G = sheetMatrix(min(noteArray)-1:max(noteArray),:);
B = rand(size(Y,1), size(G,1));
beta = 0;

Yhat = B * G;
betaDivergence = betaDivergenceMatrix(Y, Yhat, beta)

%[B, G, cost] = beta_nmf_H(Y, beta, 10, B, G);

%%
B = B .* ((Y .* (Yhat .^(beta-2) ) * G') ./ ((Yhat .^ (beta-1)) * G'));
G = G .* ( B' * (Y .* (Yhat .^(beta-2) )) ./ (B' * (Yhat .^ (beta-1))));
%B = betaNormC(B,beta);
B = normc(B);
Yhat = B * G;
betaDivergence = betaDivergenceMatrix(Y, Yhat, beta)


%%
for i = 1:5
    B = B .* ((Y .* (Yhat .^(beta-2) ) * G') ./ ((Yhat .^ (beta-1)) * G'));
    %B = betaNormC(B,beta); 
    B = normc(B);

    Yhat = B * G;
    betaDivergence = betaDivergenceMatrix(Y, Yhat, beta)


    
end  

%%

%%

MIDIFilename = 'bps131SMD.mid';


% Rewrite MIDI with fixed times
midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);


% midiPitch - 22 ( ref scale's first note is 24, and this is second coloumn of B)
sheetMatrixMidi = zeros(max(noteArray)-22, floor(midiRef(length(midiRef), 7) * 44100/nfft));


for i = 1 : length(midiRef)
    notePitch = midiRef(i,4) - 22;
    onset = floor( midiRef(i,6) * 44100 / nfft);
    offset = floor( midiRef(i,7) * 44100 / nfft);
   
    sheetMatrixMidi(notePitch, onset+1:offset+1) = 1;
end

for j = 1 :size(sheetMatrixMidi,2)
    if sum(sheetMatrixMidi(:,j)) == 0
        sheetMatrixMidi(1, j) = 1;
    end
end



imagesc(sheetMatrixMidi)

[d2,sr] = audioread('bps131SMD.mp3');

d2 = d2(:,1);

[s2, f, t] = spectrogram (d2, window, noverlap);


X = abs(s2);
X(:, length(sheetMatrixMidi) + 1 : size(X,2) ) = [];


%%
Gx = sheetMatrixMidi;
Bcopy = B;


%%
%[B, Gx, cost] = beta_nmf_H(X, beta, 10, B, Gx);

Xhat = Bcopy * Gx;
betaDivergence = betaDivergenceMatrix(X, Xhat, beta)


Bcopy = Bcopy .* ((X .* (Xhat .^(beta-2) ) * Gx') ./ ((Xhat .^ (beta-1)) * Gx'));
Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(beta-2) )) ./ (Bcopy' * (Xhat .^ (beta-1))));

%Bcopy = betaNormC(Bcopy,beta);
Bcopy = normc(Bcopy);
Bcopy(find(isnan(Bcopy)))=0;


Gx(find(isnan(Gx)))=0;
Xhat = Bcopy * Gx;  
betaDivergence = betaDivergenceMatrix(X, Xhat, beta)



%%

for i = 1:50


    Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(beta-2) )) ./ (Bcopy' * (Xhat .^ (beta-1))));
    Gx(find(isnan(Gx)))=0;
    
    Xhat = Bcopy * Gx;  
    betaDivergence = betaDivergenceMatrix(X, Xhat, beta)

end


%%
midiVel = midiRef;



for i = 1:length(midiVel)
    index = floor( midiVel(i,6) * 44100 / nfft) + 1;
    pitch = midiVel(i,4) - 22;
    midiVel(i,5) = round(log(max(Gx(pitch,index:index))) * 15);
    if midiVel(i,5) < 0
        midiVel(i,5) = 1;
    end
end

% calculate error
errorMatrix = zeros(length(midiVel),2);

for i = 1: length(midiVel)
    errorMatrix(i) = midiRef(i,4);
    errorMatrix(i,2) = abs(midiRef(i,5) - midiVel(i,5)) / midiRef(i,5);
end

error = sum(errorMatrix) / length(errorMatrix)


errorPerNote = zeros(2, max(errorMatrix(:,1)));


for i = 1 : length(errorMatrix)
    errorPerNote(1,errorMatrix(i,1)) = errorPerNote(1,errorMatrix(i,1)) + errorMatrix(i,2);
    errorPerNote(2,errorMatrix(i,1)) = errorPerNote(2,errorMatrix(i,1)) + 1;
end


result = errorPerNote(1,:) ./ errorPerNote(2,:);



