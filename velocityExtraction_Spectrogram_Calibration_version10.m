[d1,sr] = audioread('piano24velScaleYamaha.wav');
d1 = (d1(:,1) + d1(:,2))/2 ;
    
nfft = 2048;
window = nfft * 4;
noverlap = window - nfft;

[s, f, t] = spectrogram (d1, window, noverlap);
Y = abs(s);


%%
sheetMatrix = makeSheetMatrix('newScale24.mid', nfft, Y);

%%

MIDIFilename = 'newScale24.mid';


% Rewrite MIDI with fixed times
nmat = readmidi_java(MIDIFilename,true);
nmat(:,7) = nmat(:,6) + nmat(:,7);
noteArray = unique(nmat(:,4));


sheetMatrix = zeros(max(noteArray), length(Y));
%sheetMatrix = zeros(max(noteArray) , floor(nmat(length(nmat), 7) * 44100/nfft));


for i = 1: length(Y)
   timeSecond = i * nfft / 44100;
   noteNumber = floor(timeSecond/24);
   
   if mod(timeSecond,1) <= 0.8
        meanVolume = mean(sum(Y(:,i)));
        rmsVolume = abs(sqrt(sum(Y(:,i) .^2)));
        if noteNumber < 88
            sheetMatrix (noteNumber+min(noteArray), i) = meanVolume;
            %sheetMatrix (noteNumber+min(noteArray), i) = rmsVolume;
            %sheetMatrix(noteNumber + min(noteArray), i) = 1;
        end
   end
end

%

for j = 1 :size(sheetMatrix,2)
    if sum(sheetMatrix(:,j)) == 0
        sheetMatrix(min(noteArray)-1, j) = 1;
    end
end

%%

if size(Y,2) > size(sheetMatrix,2)

    Y(:, length(sheetMatrix) + 1 : length(Y) ) = [];
end
Y(Y==0) = 0.000001;
% calculate Basis matrix


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

%

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


%Bcopy = Bcopy .* ((Y .* (Xhat .^(beta-2) ) * Gtest') ./ ((Xhat .^ (beta-1)) * Gtest'));
Gtest = Gtest .* ( Bcopy' * (Y .* (Xhat .^(beta-2) )) ./ (Bcopy' * (Xhat .^ (beta-1))));

%Bcopy = betaNormC(Bcopy,beta);
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


%%
% fitting 


ydata = zeros(24, length(noteArray));

for i = 1: length(noteArray)
    velIndex = 1;
    for j = (i-1)*24 + 1: i*24
        index = floor( nmat(j,6) * 44100 / nfft) + 1;
        pitch = nmat(j,4) - 19;
        
        ydata(velIndex,i) = max(Gtest(pitch,index:index+1));
        
        velIndex = velIndex + 1;
    end
    
end



xdata = linspace(5,120,24)'; %velocity saved in original midi file

fitType=fittype('(a*x+b)');

fittingArray = zeros(3, length(noteArray)); % a, b, rsquare


for i = 1: length(noteArray)
    [fit1, gof] = fit(xdata, log(ydata(:,i)), fitType , 'StartPoint', [1 1]);
    fittingArray(:, i) = [fit1.a; fit1.b; gof.rsquare];

end

% save velocity into midi array


nmatTest = nmat;
gainDataScale = zeros(1, length(nmatTest));
%

for i = 1:length(nmatTest)
    index = floor( nmatTest(i,6) * 44100 / nfft) + 1;
    pitch = nmatTest(i,4) - 19;
    gainCalculated = max(Gtest(pitch,index:index+1));
    gainDataScale(i) = log(gainCalculated);
    coefA = fittingArray(1,pitch-1);
    coefB = fittingArray(2,pitch-1);
    
    nmatTest(i,5) = round( (log(gainCalculated) - coefB) / coefA); 
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

hold off; plot(log(G(2,1:381))); hold on; plot(log(Gtest(2,1:381)),'r')


%%
filename = 'Schiff, Andras';
MIDIFilename = strcat(filename,'-mix.mid');
MP3Filename =  strcat(filename, '.mp3');

% Rewrite MIDI with fixed times
midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);


% midiPitch - 19 ( ref scale's first note is 21, and this is second coloumn of B)
sheetMatrixMidi = zeros(max(noteArray)-19, floor(midiRef(length(midiRef), 7) * 44100/nfft));
sheetMatrixMidiRoll = zeros(max(noteArray)-19, floor(midiRef(length(midiRef), 7) * 44100/nfft));

for i = 1 : length(midiRef)
    notePitch = midiRef(i,4) - 19;
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

d2 = (d2(:,1) + d2(:,2))/2;

[s2, f, t] = spectrogram (d2, window, noverlap);


X = abs(s2);

if size(sheetMatrixMidi,2) < size(X,2)
    X(:, size(sheetMatrixMidi,2) + 1 : size(X,2) ) = [];
elseif size(sheetMatrixMidi,2) > size(X,2)
    dummyMatrix = ones(size(X,1), size(sheetMatrixMidi,2) - size(X,2)) * 0.000001;
    X = horzcat(X,dummyMatrix);
end



% Calculate Gx
Gx = sheetMatrixMidi;
Bcopy = B;

%[B, Gx, cost] = beta_nmf_H(X, beta, 10, B, Gx);

Xhat = Bcopy * Gx;
%betaDivergence = betaDivergenceMatrix(X, Xhat, beta)


Bcopy = Bcopy .* ((X .* (Xhat .^(beta-2) ) * Gx') ./ ((Xhat .^ (beta-1)) * Gx'));
Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(beta-2) )) ./ (Bcopy' * (Xhat .^ (beta-1))));

Bcopy = betaNormC(Bcopy,beta);
%Bcopy = normc(Bcopy);
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

%%
% evaluate the result
midiVel = midiRef;


gainData = zeros(length(midiVel),1);

for i = 1:length(midiVel)
    index = floor( midiVel(i,6) * 44100 / nfft) + 1;
    pitch = midiVel(i,4) - 19;
    
    gainCalculated = max(Gx(pitch,index-2:index+2));
    gainData(i) = log(gainCalculated);
    
    
    coefA = fittingArraySMDsimple(2, min(find(fittingArraySMDsimple(1,:)>=pitch-1)))/0.9;
    coefB = fittingArraySMDsimple(3, min(find(fittingArraySMDsimple(1,:)>=pitch-1)))/1.4;

    
    %coefA = fittingArraySMD(1,pitch-1);
    %coefB = fittingArraySMD(2,pitch-1);
    
    midiVel(i,5) = round( (log(gainCalculated) - (coefB ) ) / coefA )  ; 
    midiVelNorm(i) = log(gainCalculated);
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

hold off; plot(midiRef(:,5)); hold on; plot(midiVel(:,5), 'r'); hold off

%subplot(3,1,1); imagesc(db(X([1:200],r)+0.00001)); axis xy ; subplot(3,1,2); imagesc(Gx(:,r)); ; axis xy; subplot(3,1,3); imagesc(sheetMatrixMidiRoll(:,r)); ; axis xy
%hist(20*log10(gainData.^2+0.00001), 100)


%intensityRef = betaNormC(2 .^ (midiRef(:,5) * 0.04),2);
%intensityVel = betaNormC(gainData,2);

intensityRef = betaNormC(midiRef(:,5),2);
intensityVel = betaNormC(midiVel(:,5),2);




normalizedError = sum( abs( intensityRef - intensityVel) ./ intensityRef ) / length(intensityRef)
%%
targetPitch = 56;
plot(midiRef(midiRef(:,4)==targetPitch, 5)); hold on; plot(midiVel(midiVel(:,4)==targetPitch, 5)); hold off;


%%


% fitting

%

%ydataSMD = zeros(1000, length(noteArray));
%xdataSMD = zeros(1000, length(noteArray));



for i = 1 : length(midiRef)
    index = floor( midiRef(i,6) * 44100 / nfft) + 1;
    pitch = midiRef(i,4) - 19;


    dataIndex = min(find(ydataSMD(:,pitch)==0));
    ydataSMD(dataIndex,pitch) = max(Gx(pitch,index:index+2));
    xdataSMD(dataIndex,pitch) = midiRef(i,5);     
end


%%

fitType=fittype('(a*x+b)');
fittingArraySMD = zeros(3, length(noteArray)); % a, b, rsquare



%%



for i = 1: length(noteArray)
    if max(find(xdataSMD(:,i))) > 5
        dataSize = min(find(xdataSMD(:,i)==0)) -1;
        [fit1, gof] = fit(xdataSMD(1:dataSize,i), log(ydataSMD(1:dataSize,i)), fitType , 'StartPoint', [1 1]);
        fittingArraySMD(:, i) = [fit1.a; fit1.b; gof.rsquare];
    end
    
end

%%

ydataSMDLow = zeros(10000,1);
xdataSMDLow = zeros(10000,1);
LowOctaveIndex = 1;
for i = 55:65
    dataLength = min(find(ydataSMD(:,i)==0)) - 1;
    ydataSMDLow(LowOctaveIndex:LowOctaveIndex+dataLength-1) = ydataSMD(1:dataLength, i);
    xdataSMDLow(LowOctaveIndex:LowOctaveIndex+dataLength-1) = xdataSMD(1:dataLength, i);
    
end


ydataSMDLow(find(ydataSMDLow==0),:) = [];
xdataSMDLow(find(xdataSMDLow==0),:) = [];


[fit1, gof] = fit(xdataSMDLow, log(ydataSMDLow), fitType , 'StartPoint', [1 1]);
[fittingArraySMDLow] = [fit1.a; fit1.b; gof.rsquare];
gof.rsquare;

%%

ydataSMDMiddle = zeros(10000,1);
xdataSMDMiddle = zeros(10000,1);
MiddleOctaveIndex = 1;
for i = 40:62
    dataLength = min(find(ydataSMD(:,i)==0)) - 1;
    ydataSMDMiddle(MiddleOctaveIndex:MiddleOctaveIndex+dataLength-1) = ydataSMD(1:dataLength, i);
    xdataSMDMiddle(MiddleOctaveIndex:MiddleOctaveIndex+dataLength-1) = xdataSMD(1:dataLength, i);
    
end


ydataSMDMiddle(find(ydataSMDMiddle==0),:) = [];
xdataSMDMiddle(find(xdataSMDMiddle==0),:) = [];


[fit1, gof] = fit(xdataSMDMiddle, log(ydataSMDMiddle), fitType , 'StartPoint', [1 1]);
[fittingArraySMDMiddle] = [fit1.a; fit1.b; gof.rsquare];

%%
ydataSMDHigh = zeros(10000,1);
xdataSMDHigh = zeros(10000,1);
HighOctaveIndex = 1;
for i = 70:88
    dataLength = min(find(ydataSMD(:,i)==0)) - 1;
    ydataSMDHigh(HighOctaveIndex:HighOctaveIndex+dataLength-1) = ydataSMD(1:dataLength, i);
    xdataSMDHigh(HighOctaveIndex:HighOctaveIndex+dataLength-1) = xdataSMD(1:dataLength, i);
    
end


ydataSMDHigh(find(ydataSMDHigh==0),:) = [];
xdataSMDHigh(find(xdataSMDHigh==0),:) = [];


[fit1, gof] = fit(xdataSMDHigh, log(ydataSMDHigh), fitType , 'StartPoint', [1 1]);
[fittingArraySMDHigh] = [fit1.a; fit1.b; gof.rsquare];



%%

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

%%

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

audioDynamicRange = searchIndexRight - searchIndexLeft
