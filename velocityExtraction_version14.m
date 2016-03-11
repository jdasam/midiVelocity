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


sheetMatrix = zeros(max(noteArray), length(Y));
%sheetMatrix = zeros(max(noteArray) , floor(nmat(length(nmat), 7) * 44100/nfft));


for i = 1: length(Y)
   timeSecond = i * nfft / 44100;
   noteNumber = floor(timeSecond/18);
   
   if mod(timeSecond,3) <= 2.4
        rmsVolume = abs(sqrt(sum(Y(:,i) .^2)));
        if noteNumber < 85
            sheetMatrix (noteNumber+min(noteArray), i) = rmsVolume;
        end
   end
end

for j = 1 :size(sheetMatrix,2)
    if sum(sheetMatrix(:,j)) == 0
        sheetMatrix(min(noteArray)-1, j) = 1;
    end
end


if size(Y,2) > size(sheetMatrix,2)

    Y(:, length(sheetMatrix) + 1 : length(Y) ) = [];
end
Y(Y==0) = 0.000001;
%% calculate Basis matrix


G = sheetMatrix(min(noteArray)-1:max(noteArray),:);
B = rand(size(Y,1), size(G,1));
beta = 1;

Yhat = B * G;
betaDivergence = betaDivergenceMatrix(Y, Yhat, beta)

%[B, G, cost] = beta_nmf_H(Y, beta, 10, B, G);


B = B .* ((Y .* (Yhat .^(beta-2) ) * G') ./ ((Yhat .^ (beta-1)) * G'));
%G = G .* ( B' * (Y .* (Yhat .^(beta-2) )) ./ (B' * (Yhat .^ (beta-1))));
%B = betaNormC(B,beta);
%B = normc(B);
Yhat = B * G;
betaDivergence = betaDivergenceMatrix(Y, Yhat, beta)



for i = 1:3
    B = B .* ((Y .* (Yhat .^(beta-2) ) * G') ./ ((Yhat .^ (beta-1)) * G'));
    %B = betaNormC(B,beta); 
    %B = normc(B);

    Yhat = B * G;
    betaDivergence = betaDivergenceMatrix(Y, Yhat, beta)
end  

%% Fitting

sheetMatrixTest = zeros(size(sheetMatrix));



for i = 1 : length(nmat)
    notePitch = nmat(i,4);
    onset = floor( nmat(i,6) * 44100 / nfft);
    offset = floor( nmat(i,7) * 44100 / nfft);
    sheetMatrixTest (notePitch, onset+1:offset+1) = 1;
    %sheetMatrix (notePitch, onset+1:onset+4) = 2 ^ (nmat(i,5)/15);
end

for j = 1 :size(sheetMatrixTest,2)
    if sum(sheetMatrixTest(:,j)) == 0
        sheetMatrixTest(min(noteArray)-1, j) = 1;
    end
end

% Calculate gain matrix reversely
Gtest = sheetMatrixTest(min(noteArray)-1:max(noteArray),:);
Bcopy = B;


if size(Gtest,2) > size(Y,2)

    Gtest(:, length(Y) + 1 : length(Gtest) ) = [];

end



Xhat = Bcopy * Gtest;

betaDivergence = betaDivergenceMatrix(Y, Xhat, beta)


Bcopy = Bcopy .* ((Y .* (Xhat .^(beta-2) ) * Gtest') ./ ((Xhat .^ (beta-1)) * Gtest'));
Gtest = Gtest .* ( Bcopy' * (Y .* (Xhat .^(beta-2) )) ./ (Bcopy' * (Xhat .^ (beta-1))));

Bcopy = betaNormC(Bcopy,beta);
%Bcopy = normc(Bcopy);
Bcopy(find(isnan(Bcopy)))=0;


Gtest(find(isnan(Gtest)))=0;
Xhat = Bcopy * Gtest;  
betaDivergence = betaDivergenceMatrix(Y, Xhat, beta)



 
for i = 1:3


    Gtest = Gtest .* ( Bcopy' * (Y .* (Xhat .^(beta-2) )) ./ (Bcopy' * (Xhat .^ (beta-1))));
    Gtest(find(isnan(Gtest)))=0;
    
    Xhat = Bcopy * Gtest;
    betaDivergence = betaDivergenceMatrix(Y, Xhat, beta)

end


% fitting 


ydata = zeros(6, length(noteArray));

for i = 1: length(noteArray)
    velIndex = 1;
    for j = (i-1)*6 + 1: i*6
        index = floor( nmat(j,6) * 44100 / nfft) + 1;
        pitch = nmat(j,4) - 22;
        
        ydata(velIndex,i) = max(Gtest(pitch,index:index+1));
        
        velIndex = velIndex + 1;
    end
    
end


xdata = [20; 40; 60; 80; 100; 120]; %velocity saved in original midi file

fitType=fittype('(a*x+b)^2');

fittingArray = zeros(3, length(noteArray)); % a, b, rsquare

for i = 1: length(noteArray)
    [fit1, gof] = fit(xdata, ydata(:,i), fitType , 'StartPoint', [1 1]);
    fittingArray(:, i) = [fit1.a; fit1.b; gof.rsquare];

end
% save velocity into midi array


nmatTest = nmat;
gainDataScale = zeros(1, length(nmatTest));


for i = 1:length(nmatTest)
    index = floor( nmatTest(i,6) * 44100 / nfft) + 1;
    pitch = nmatTest(i,4) - 22;
    gainCalculated = max(Gtest(pitch,index:index+1));
    gainDataScale(i) = sqrt(gainCalculated);
    coefA = fittingArray(1,pitch-1);
    coefB = fittingArray(2,pitch-1);
    
    nmatTest(i,5) = round( (sqrt(gainCalculated) - coefB) / coefA); 
    %nmatTest(i,5) = round(sqrt(max(Gtest(pitch,index:index+1))) * 2);
    if nmatTest(i,5) <= 0
        nmatTest(i,5) = 1;
    end
end

% calculate error
errorMatrix = zeros(length(nmatTest),2);

for i = 1: length(nmatTest)
    errorMatrix(i) = nmat(i,4);
    errorMatrix(i,2) = abs(nmat(i,5) - nmatTest(i,5)) / nmat(i,5);
end

error = sum(errorMatrix) / length(errorMatrix)


errorPerNote = zeros(2, max(errorMatrix(:,1)));


for i = 1 : length(errorMatrix)
    errorPerNote(1,errorMatrix(i,1)) = errorPerNote(1,errorMatrix(i,1)) + errorMatrix(i,2);
    errorPerNote(2,errorMatrix(i,1)) = errorPerNote(2,errorMatrix(i,1)) + 1;
end


result = errorPerNote(1,:) ./ errorPerNote(2,:);



intensityRef = betaNormC(nmat(:,5),2);
intensityVel = betaNormC(gainDataScale',2);


normalizedError = sum( abs( intensityRef - intensityVel) ./ intensityRef ) / length(intensityRef)


%%
filename = 'Beethoven_Op027No1-01_003_20090916-SMD';
MIDIFilename = strcat(filename,'.mid');
MP3Filename =  strcat(filename, '.mp3');



% Rewrite MIDI with fixed times
midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);


% midiPitch - 22 ( ref scale's first note is 24, and this is second coloumn of B)
sheetMatrixMidi = zeros(max(noteArray)-22, floor(midiRef(length(midiRef), 7) * 44100/nfft));
sheetMatrixMidiRoll = zeros(max(noteArray)-22, floor(midiRef(length(midiRef), 7) * 44100/nfft));

for i = 1 : length(midiRef)
    notePitch = midiRef(i,4) - 22;
    onset = floor( midiRef(i,6) * 44100 / nfft) + 1;
    offset = floor( midiRef(i,7) * 44100 / nfft) + 1;

    sheetMatrixMidi(notePitch, onset:offset) = 0.2;
    sheetMatrixMidi(notePitch, onset-2:onset+2) = [0.3, 0.6, 1, 0.6, 0.3];
    
    sheetMatrixMidiRoll(notePitch, onset:offset) = 1;
    
end




for j = 1 :size(sheetMatrixMidi,2)
    if sum(sheetMatrixMidi(:,j)) == 0
        sheetMatrixMidi(1, j) = 1;
    end
end



imagesc(sheetMatrixMidi)

[d2,sr] = audioread(MP3Filename);

d2 = d2(:,1);

[s2, f, t] = spectrogram (d2, window, noverlap);


X = abs(s2);

if (size (X,2) > length(sheetMatrixMidi))
    X(:, length(sheetMatrixMidi) + 1 : size(X,2) ) = [];
elseif (size (X,2) < length(sheetMatrixMidi))
    dummyMatrix = ones( size(X,1) ,length(sheetMatrixMidi) - size(X,2));
    X = horzcat(X, dummyMatrix * 0.000001);
end




% Calculate Gx
Gx = sheetMatrixMidi;
Bcopy = B;


Xhat = Bcopy * Gx;
%betaDivergence = betaDivergenceMatrix(X, Xhat, beta)


Bcopy = Bcopy .* ((X .* (Xhat .^(beta-2) ) * Gx') ./ ((Xhat .^ (beta-1)) * Gx'));
Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(beta-2) )) ./ (Bcopy' * (Xhat .^ (beta-1))));

Bcopy = betaNormC(Bcopy,beta);
Bcopy(find(isnan(Bcopy)))=0;


Gx(find(isnan(Gx)))=0;
Xhat = Bcopy * Gx;  
%betaDivergence = betaDivergenceMatrix(X, Xhat, beta)




for i = 1:50

    %Bcopy = Bcopy .* ((X .* (Xhat .^(beta-2) ) * Gx') ./ ((Xhat .^ (beta-1)) * Gx'));
    Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(beta-2) )) ./ (Bcopy' * (Xhat .^ (beta-1))));
    Gx(find(isnan(Gx)))=0;
    %Bcopy = betaNormC(Bcopy,beta);
    %Bcopy(find(isnan(Bcopy)))=0;

    Xhat = Bcopy * Gx;  
    %betaDivergence = betaDivergenceMatrix(X, Xhat, beta)

end


% evaluate the result
midiVel = midiRef;
midiVelNorm = midiVel(:,5);


gainData = zeros(1, length(midiVel));

for i = 1:length(midiVel)
    index = floor( midiVel(i,6) * 44100 / nfft) + 1;
    pitch = midiVel(i,4) - 22;
    
    gainCalculated = max(Gx(pitch,index-2:index+2));
    gainData(i) = sqrt(gainCalculated);
    coefA = fittingArray(1,pitch-1);
    coefB = fittingArray(2,pitch-1);

    
    midiVel(i,5) = round( (sqrt(gainCalculated) - coefB) / coefA) ; 
    midiVelNorm(i) = sqrt(gainCalculated);
    %midiVel(i,5) = round(sqrt(max(Gx(pitch,index:index))) * 2.5);
    if midiVel(i,5) < 0
        midiVel(i,5) = 0;
    end
    if midiVel(i,5) > 127
        midiVel(i,5) = 127;
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

if midiVel(10,7) > midiVel(10,6)
    midiVel(:,7) = midiRef(:,7) - midiVel(:,6);
end

writemidi_seconds(midiVel, 'testout.mid');

plot(midiRef(:,5))
hold on
plot(midiVel(:,5), 'r')
hold off

%subplot(3,1,1); imagesc(db(X([1:200],r)+0.00001)); axis xy ; subplot(3,1,2); imagesc(Gx(:,r)); ; axis xy; subplot(3,1,3); imagesc(sheetMatrixMidiRoll(:,r)); ; axis xy
%hist(20*log10(gainData.^2+0.00001), 100)


intensityRef = betaNormC(midiRef(:,5),2);
intensityVel = betaNormC(midiVelNorm,2);


normalizedError = sum( abs( intensityRef - intensityVel) ./ intensityRef ) / length(intensityRef)




% histogram and dynamic 
coverage = 0.95;


histData = histogram(midiRef(:,5), max(midiRef(:,5)) - min(midiRef(:,5)) + 1);
cumHist = zeros(1, length(histData.Values));
cumHist(1) = histData.Values(1);

for i = 2: length(cumHist)
    cumHist(i) = histData.Values(i) + cumHist(i-1);
end

searchIndex = find(cumHist == max(cumHist(cumHist < length(histData.Data) / 2)));
searchIndexRight = searchIndex + 1;
searchIndexLeft = searchIndex -1;
calcHist = histData.Values(searchIndex);


while calcHist < length(histData.Data) * coverage    
    if histData.Values(searchIndexLeft) > histData.Values(searchIndexRight)
        calcHist = calcHist + histData.Values(searchIndexLeft);
        searchIndexLeft = searchIndexLeft - 1;
    else
        calcHist = calcHist + histData.Values(searchIndexRight);
        searchIndexRight = searchIndexRight + 1;
    end
    
    if searchIndexRight > histData.NumBins;
        while calcHist < length(histData.Data) * coverage
            calcHist = calcHist + histData.Values(searchIndexLeft);
            searchIndexLeft = searchIndexLeft - 1;
        end
    end
    
    if searchIndexLeft == 0
        while calcHist < length(histData.Data) * coverage  
            calcHist = calcHist + histData.Values(searchIndexRight);
            searchIndexRight = searchIndexRight + 1;
        end
    end        

end


midiDynamicRange = searchIndexRight - searchIndexLeft



histData = histogram(20* log10(gainData), 100);
cumHist = zeros(1, length(histData.Values));
cumHist(1) = histData.Values(1);

for i = 2: length(cumHist)
    cumHist(i) = histData.Values(i) + cumHist(i-1);
end


searchIndex = find(cumHist == max(cumHist(cumHist < length(histData.Data) / 2)));
searchIndexRight = searchIndex + 1;
searchIndexLeft = searchIndex -1;
calcHist = histData.Values(searchIndex);


while calcHist < length(histData.Data) * coverage    
    if histData.Values(searchIndexLeft) > histData.Values(searchIndexRight)
        calcHist = calcHist + histData.Values(searchIndexLeft);
        searchIndexLeft = searchIndexLeft - 1;
    else
        calcHist = calcHist + histData.Values(searchIndexRight);
        searchIndexRight = searchIndexRight + 1;
    end
    
    if searchIndexRight > histData.NumBins;
        while calcHist < length(histData.Data) * coverage
            calcHist = calcHist + histData.Values(searchIndexLeft);
            searchIndexLeft = searchIndexLeft - 1;
        end
    end
    
    if searchIndexLeft == 0
        while calcHist < length(histData.Data) * coverage  
            calcHist = calcHist + histData.Values(searchIndexRight);
            searchIndexRight = searchIndexRight + 1;
        end
    end        

end

audioDynamicRange = histData.BinEdges(searchIndexRight) - histData.BinEdges(searchIndexLeft)

velocityMedian = median(midiRef(:,5))

%%
intensityRef = betaNormC((1*midiRef(:,5) +11).^2,2);
intensityVel = betaNormC((1*midiVelNorm +7).^2,2);
normalizedError = sum( abs( intensityRef - intensityVel) ./ intensityRef ) / length(intensityRef)
