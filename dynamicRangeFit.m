filename = 'Bavouzet, Jean-Efflam';
MIDIFilename = strcat(filename,'.mid');
MP3Filename =  strcat(filename, '.wav');
% basicParameter.nfft = 441;
% basicParameter.searchRange = 50;
basicParameter.targetMedian = 65;
basicParameter.targetRange = 18;
basicParameter.spectrumRank = 2;
% basicParameter.onsetFine = 10;
% basicParameter.threshold = 0.001;
% basicParameter.transcription = true;
basicParameter.attackExceptRange = 10;
% basicParameter.attackLengthFrame = 25;
basicParameter.updateBnumber = 5;

[Gx, midiVel, tempError, tempErrorByNote, tempCompare, maxIndexVector, histogramData] = velocityExtractionOption(MP3Filename, MIDIFilename, B, basicParameter);

%
saveName = strcat(filename, '_vel.mid');
writemidi_seconds(midiVel, saveName);

%%
histData = zeros(15,4);
for i = 1:15
    histData(i,1) = resultData.histogramData{1,i}.f.b1;
    histData(i,2) = resultData.histogramData{1,i}.f.c1;
    histData(i,3) = resultData.histogramData{1,i}.f2.b1;
    histData(i,4) = resultData.histogramData{1,i}.f2.c1;
    
end

%%
[lassoAll, stats] = lasso(histData(:,1), histData(:,3), 'CV', 5);
basicParameter.dynMed = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];
[lassoAll, stats] = lasso(histData(:,2), histData(:,4), 'CV', 5);
basicParameter.dynRan = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];

%%
plot(histData(22:34,4), histData(22:34,2), 'k+')