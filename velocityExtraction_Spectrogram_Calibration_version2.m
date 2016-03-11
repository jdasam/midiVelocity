[d1,sr] = audioread('piano24velScaleYamaha.wav');
d1 = (d1(:,1) + d1(:,2))/2 ;
    
nfft = 2048;
window = nfft * 4;
noverlap = window - nfft;

[s, f, t] = spectrogram (d1, window, noverlap);
Y = abs(s);
basicParameter = [];
basicParameter.sr = sr;
basicParameter.nfft = nfft;

%%
[sheetMatrix, basicParameter.minNote, basicParameter.maxNote, basicParameter.MIDI] = makeSheetMatrix('newScale24.mid', nfft, Y);

basicParameter.beta = 1;

%%
if size(Y,2) > size(sheetMatrix,2)

    Y(:, length(sheetMatrix) + 1 : length(Y) ) = [];
end
Y(Y==0) = 0.000001;

% calculate Basis matrix
[G, B] = basisNMF(Y, sheetMatrix, basicParameter.beta);

%%
[sheetMatrixTest, Gtest, Bcopy] = makeSheetMatrixTest(sheetMatrix,Y, B, basicParameter);
%%
% fitting 
xdata = linspace(5,120,24)'; %velocity saved in original midi file
[fittingArray, errorByNote] = fittingByNote(Gtest, xdata, basicParameter);


%% 
resultData = [];
resultData.title = {};
resultData.drParameter = [];
resultData.error = [];
resultData.velTruth = [];
resultData.xSMD = zeros(3000, basicParameter.maxNote - basicParameter.minNote + 1);
resultData.ySMD = zeros(3000, basicParameter.maxNote - basicParameter.minNote + 1);

%%
filename = 'Beethoven_Op031No2-02_002_20090916-SMD';
MIDIFilename = strcat(filename,'.mid');
MP3Filename =  strcat(filename, '.mp3');

[midiVel, Gx, basicParameter.dr, basicParameter.error, basicParameter.velTruth] = velocityExtraction(MP3Filename, MIDIFilename, B, fittingArraySMDsimple, basicParameter);


%resultData.title(size(resultData.title, 1)+1,1) = filename;
resultData.title(size(resultData.title,1)+1,:) = cellstr(filename);
resultData.drParameter(:,size(resultData.drParameter,2)+1) = [basicParameter.dr.a1; basicParameter.dr.b1; basicParameter.dr.c1];
resultData.error(:,size(resultData.error,2)+1) = basicParameter.error;
resultData.velTruth(:,size(resultData.velTruth,2)+1) = [basicParameter.velTruth.a1; basicParameter.velTruth.b1; basicParameter.velTruth.c1];

% fitting

%ydataSMD = zeros(1000, basicParameter.maxNote - basicParameter.minNote + 1);
%xdataSMD = zeros(1000, basicParameter.maxNote - basicParameter.minNote + 1);


midiRef = readmidi_java(MIDIFilename,true);

for i = 1 : length(midiRef)
    index = ceil( midiRef(i,6) * basicParameter.sr / basicParameter.nfft);
    pitch = midiRef(i,4) - 19;
    
    if index < 1
        index = 1;
    end

    dataIndex = min(find(resultData.ySMD(:,pitch)==0));
    resultData.ySMD(dataIndex,pitch) = max(Gx(pitch,index-2:index+2));
    resultData.xSMD(dataIndex,pitch) = midiRef(i,5);     
end



%%
targetPitch = 40;
midiRef = readmidi_java(MIDIFilename,true);
plot(midiRef(midiRef(:,4)==targetPitch, 5)); hold on; plot(midiVel(midiVel(:,4)==targetPitch, 5)); hold off;

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


ydataSMDLow = zeros(100000,1);
xdataSMDLow = zeros(100000,1);
LowOctaveIndex = 1;
for i = 81:88
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
