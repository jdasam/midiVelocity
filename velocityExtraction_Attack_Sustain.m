[d1,sr] = audioread('pianoScale12staccato2.mp3');
d1 = (d1(:,1) + d1(:,2))/2 ;
    
nfft = 2048;
window = nfft * 4;
noverlap = window - nfft;

[s, f, t] = spectrogram (d1, window, noverlap);
Y = abs(s);
Y(Y==0) = 0.0000001;
%
basicParameter = [];
basicParameter.sr = sr;
basicParameter.nfft = nfft;
basicParameter.velMod = 12;
basicParameter.noteLength = 2;
basicParameter.noteSoundRatio = 0.7;
basicParameter.attackLengthRatio = 0.07;
basicParameter.attackLengthFrame = 3;
basicParameter.beta = 1;
basicParameter.window = window;
basicParameter.MIDIFilename = 'pianoScale12Staccato2.mid';
basicParameter.fittingArray = zeros(2,88);
basicParameter.alpha = 0;
%basicParameter.hopSize = nfft;

%%
[basicParameter.minNote, basicParameter.maxNote, basicParameter.MIDI] = readScale(basicParameter);

sheetMatrix = midi2Matrix(basicParameter.MIDI, length(Y), basicParameter);


% calculate Basis matrix
[G, B] = basisNMFAnSpower(Y, sheetMatrix, basicParameter.beta);

%% Test backward
[sheetMatrixTest, Gtest, Bcopy] = makeSheetMatrixTestAnS(sheetMatrix,Y, B, basicParameter);
% fitting   
xdata = linspace(10,120,basicParameter.velMod)'; %velocity saved in original midi file
[fittingArray, errorByNote, ydata, nmatTest] = fittingByNoteAS(Gtest, xdata, basicParameter);


%%
dataSet = getFileListWithExtension('*.mp3');



ydataSMD = zeros(5000, 88);
xdataSMD = zeros(5000, 88);

for j = 1:length(dataSet)
    
    filename = char(dataSet(j));
    MIDIFilename = strcat(filename,'.mid');
    MP3Filename =  strcat(filename, '.mp3');

    [Gx] = velocityExtractionAnSpower(MP3Filename, MIDIFilename, B, basicParameter);

    midiRef = readmidi_java(MIDIFilename,true);

    for i = 1 : length(midiRef)
        pitch = midiRef(i,4);
        index = ceil( ( midiRef(i,6) * basicParameter.sr - basicParameter.window /2 )/ basicParameter.nfft);

        dataIndex = min(find(ydataSMD(:,pitch-basicParameter.minNote+1)==0));

        ydataSMD(dataIndex,pitch-basicParameter.minNote+1) = max(Gx(2 + (pitch - basicParameter.minNote) * 2,index:index+3));
        xdataSMD(dataIndex,pitch-basicParameter.minNote+1) = midiRef(i,5);
    end


end


fittingArraySMD = zeros(2,88);

for i = 1: 88
    if max(find(xdataSMD(:,i))) > 5
        dataSize = min(find(xdataSMD(:,i)==0)) -1;
        [lassoAll, stats] = lasso(xdataSMD(1:max(find(xdataSMD(:,i))),i), log(ydataSMD(1:max(find(xdataSMD(:,i))),i)), 'CV', 5);
        fittingArraySMD(:, i) = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];
    end
end


%
fitMin = min(find(fittingArraySMD(1,:)));
fitMax = max(find(fittingArraySMD(1,:)));


for j = 1:88
    if fittingArraySMD(1,j) == 0
        if j < fitMin
           fittingArraySMD(:,j) =  fittingArraySMD(:,fitMin);
        else
           fittingArraySMD(:,j) =  fittingArraySMD(:,fitMax);
        end
    end
end

basicParameter.fittingArray = fittingArraySMD;
%% 
resultData = [];
resultData.title = {};
resultData.drParameter = [];
resultData.error = [];
resultData.velTruth = [];
resultData.errorByNote = {};
resultData.compareRefVel = {};
%resultData.xSMD = zeros(3000, basicParameter.maxNote - basicParameter.minNote + 1);
%resultData.ySMD = zeros(3000, basicParameter.maxNote - basicParameter.minNote + 1);
%%

dataSet = getFileListWithExtension('*.mp3');
basicParameter.attackLengthFrame = 4;
basicParameter.alpha = 500;
for i=1:length(dataSet)
    tic
    filename = char(dataSet(i));
    %filename = 'Skryabin_Op008No8_003_20090916-SMD';
    MIDIFilename = strcat(filename,'.mid');
    MP3Filename =  strcat(filename, '.mp3');

    %basicParameter.targetVelMean = 45; %
    %basicParameter.targetVelRange = 30; %
    %basicParameter.hopSize = 2048;

    [Gx, midiVel, tempError, tempErrorByNote, tempCompare] = velocityExtractionAnSpowerTemporal(MP3Filename, MIDIFilename, B, basicParameter);

    %[midiVel, Gx, basicParameter.dr, basicParameter.error, basicParameter.velTruth] = velocityExtractionModified(MP3Filename, MIDIFilename, B, fittingArrayVer2, basicParameter);
    %[midiVel, Gx, basicParameter.dr, basicParameter.error, basicParameter.velTruth] = velocityExtractionBasic(MP3Filename, MIDIFilename, B, fittingArraySMDsimple, basicParameter);

    toc


    resultData.errorByNote{size(resultData.errorByNote,2)+1} = tempErrorByNote(:, basicParameter.minNote:length(tempErrorByNote)) ;
    resultData.compareRefVel{size(resultData.compareRefVel,2)+1} = tempCompare;
    resultData.title(size(resultData.title,1)+1,:) = cellstr(filename);
    resultData.error(:,size(resultData.error,2)+1) = tempError;

    plot(Gx(127,:))
end
%%


%%
% fitting

%

ydataSMD = zeros(1000, 88);
xdataSMD = zeros(1000, 88);
%%
midiRef = readmidi_java(MIDIFilename,true);


for i = 1 : length(midiRef)
    pitch = midiRef(i,4);
    index = ceil( ( midiRef(i,6) * basicParameter.sr - basicParameter.window /2 )/ basicParameter.nfft);

    dataIndex = min(find(ydataSMD(:,pitch-basicParameter.minNote+1)==0));

    ydataSMD(dataIndex,pitch-basicParameter.minNote+1) = max(Gx(2 + (pitch - basicParameter.minNote) * 2,index:index+3));
    xdataSMD(dataIndex,pitch-basicParameter.minNote+1) = midiRef(i,5);
end

%%

fitType=fittype('(a*x+b)');
fittingArraySMD = zeros(3, 88); % a, b, rsquare



%%



for i = 1: 88
    if max(find(xdataSMD(:,i))) > 5
        dataSize = min(find(xdataSMD(:,i)==0)) -1;
        [fit1, gof] = fit(xdataSMD(1:dataSize,i), log(ydataSMD(1:dataSize,i)), fitType , 'StartPoint', [1 1]);
        fittingArraySMD(:, i) = [fit1.a; fit1.b; gof.rsquare];
    end
    
end

%%

for i = 1: 88
    if max(find(xdataSMD(:,i))) > 5
        dataSize = min(find(xdataSMD(:,i)==0)) -1;
        [fit1, gof] = fit(xdataSMD(1:dataSize,i), log(ydataSMD(1:dataSize,i)), fitType , 'StartPoint', [1 1]);
        test = lasso(xdataSMD(1:dataSize,i),log(ydataSMD(1:dataSize,i)));
    end
    
end



%%
%resultData.title(size(resultData.title, 1)+1,1) = filename;
resultData.title(size(resultData.title,1)+1,:) = cellstr(filename);
resultData.drParameter(:,size(resultData.drParameter,2)+1) = [basicParameter.dr.a1; basicParameter.dr.b1; basicParameter.dr.c1];
resultData.error(:,size(resultData.error,2)+1) = basicParameter.error;
resultData.velTruth(:,size(resultData.velTruth,2)+1) = [basicParameter.velTruth.a1; basicParameter.velTruth.b1; basicParameter.velTruth.c1];
%% NMF
[Vhat, H]= NMFtest(MP3Filename, MIDIFilename, B, fittingArrayVer2, basicParameter);

[x, t] = istft(Vhat, 2048, 8192, 44100);
soundsc(x,44100)
%%
expandedB = zeros(size(B,1), size(B,2) * ceil(44100 / 2048));
for i = 1 : size(B,2)
    expandedB(:,(i-1)* ceil(44100 / 2048)+1 :i * ceil(44100 / 2048)) = repmat(B(:,i), 1,  ceil(44100 / 2048));
end
    

[x, t] = istft(expandedB, 2048, 8192, 44100);
soundsc(x,44100)


%%
%
midiRef = readmidi_java(MIDIFilename,true);
errorVector = abs(midiRef(:,5) - midiVel(:,5)) ./ midiRef(:,5);
hold off; plot(midiRef(:,5)); hold on; plot(midiVel(:,5))

% fitting

for i = 1 : length(midiRef)
    index = ceil( midiRef(i,6) * basicParameter.sr / basicParameter.nfft);
    pitch = midiRef(i,4) - 20;
    
    if index < 1
        index = 1;
    end

    dataIndex = min(find(resultData.ySMD(:,pitch)==0));
    resultData.ySMD(dataIndex,pitch) = max(Gx(pitch,index-2:index+2));
    resultData.xSMD(dataIndex,pitch) = midiRef(i,5);     
end

%%
hold off
scatter(resultData.drParameter(3,1:11), resultData.velTruth(3,1:11))

fitType=fittype('(a*x+b)');
[fitMean, gof] = fit(resultData.drParameter(2,1:13)', resultData.velTruth(2,1:13)', fitType);
[fitRange, gof] = fit(resultData.drParameter(3,1:13)', resultData.velTruth(3,1:13)', fitType);


resultData.velGain(1:2, 1) = [fitMean.a ; fitMean.b];
resultData.velGain(1:2, 2) = [fitRange.a; fitRange.b];
%hold on
%scatter(resultData.drParameter(2,14:19), resultData.velTruth(2,14:19))



%%
targetPitch = 50;
midiRef = readmidi_java(MIDIFilename,true);
plot(midiRef(midiRef(:,4)==targetPitch, 5)); hold on; plot(midiVel(midiVel(:,4)==targetPitch, 5)); hold off;

sum(abs(midiRef(:,5) - midiVel(:,5))) / length(midiRef)


%%

fitType=fittype('(a*x+b)');
fittingArraySMD = zeros(3, 88); % a, b, rsquare



%%



for i = 1: 88
    if max(find(resultData.xSMD(:,i))) > 5
        dataSize = max(find(resultData.xSMD(:,i)~=0));
        [fit1, gof] = fit(resultData.xSMD(1:dataSize,i), log(resultData.ySMD(1:dataSize,i)), fitType , 'StartPoint', [1 1]);
        fittingArraySMD(:, i) = [fit1.a; fit1.b; gof.rsquare];
    end
    
end

%%
hold off
fitType=fittype('(a*x+b)');

ydataSMDLow = zeros(100000,1);
xdataSMDLow = zeros(100000,1);
LowOctaveIndex = 1;
for i =  10:40
    dataLength = max(find(resultData.ySMD(:,i)~=0));
    ydataSMDLow(LowOctaveIndex:LowOctaveIndex+dataLength-1) = resultData.ySMD(1:dataLength, i);
    xdataSMDLow(LowOctaveIndex:LowOctaveIndex+dataLength-1) = resultData.xSMD(1:dataLength, i);
    
    if dataLength
        LowOctaveIndex = LowOctaveIndex+dataLength;
    end
end

ydataSMDLow(find(ydataSMDLow==0),:) = [];
xdataSMDLow(find(xdataSMDLow==0),:) = [];


[fit1, gof] = fit(xdataSMDLow, log(ydataSMDLow), fitType , 'StartPoint', [1 1]);
plot(fit1, xdataSMDLow, log(ydataSMDLow))

[fittingArraySMDLow] = [fit1.a; fit1.b; gof.rsquare];



%%
scatter(xdataSMDLow, log(ydataSMDLow), 5,'blue','filled', 'c')
set(gca,'FontSize',18)
xlabel('Velocity', 'FontSize', 20)
ylabel('Intensity (log)', 'FontSize', 20)
axis([0 127 0 9])

%%

ydataSMDLow = zeros(10000,1);
xdataSMDLow = zeros(10000,1);
LowOctaveIndex = 1;
for i = 30:39
    dataLength = min(find(ydataSMD(:,i)==0)) - 1;
    ydataSMDLow(LowOctaveIndex:LowOctaveIndex+dataLength-1) = ydataSMD(1:dataLength, i);
    xdataSMDLow(LowOctaveIndex:LowOctaveIndex+dataLength-1) = xdataSMD(1:dataLength, i);
    
end


ydataSMDLow(find(ydataSMDLow==0),:) = [];
xdataSMDLow(find(xdataSMDLow==0),:) = [];


[fit1, gof] = fit(xdataSMDLow, log(ydataSMDLow), fitType , 'StartPoint', [1 1]);
[fittingArraySMDLow] = [fit1.a; fit1.b; gof.rsquare];

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
