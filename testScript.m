

resultName = 'R8dataS2Gpre20Ubn15UibId100Hb15postItr30_20_1_50_1_1000cluster';
resultFileName = strcat(resultName, '.mat');

basicParameter.bExtSecond = 0;
basicParameter.fExtSecond = 0;
basicParameter.usePseudoAligned = true;
[error, numberOfNotesByError]  = velocityOfPseudoAligned(pwd, B, fittingArrayCell, basicParameter, resultData.title);

save(resultFileName, 'error', 'numberOfNotesByError');

%%
resultName = 'R5S2Ubn5Gpre20aa5Ext04';
resultFileName = strcat(resultName, '.mat');

basicParameter.bExtSecond = 0.4;
basicParameter.fExtSecond = 0.4;
basicParameter.usePseudoAligned = true;
[error, numberOfNotesByError]  = velocityOfPseudoAligned(pwd, B, fittingArrayCell, basicParameter, resultData.title);

save(resultFileName, 'error', 'numberOfNotesByError');

%%
fileName = 'Chopin_Op010-03_007_20100611-SMD';
audioFilename = strcat(fileName, '.mp3');
MIDIFilename = strcat(fileName, '.mid');

B = Bcell{3,1};
basicParameter.fittingArray = fittingArrayCell{3,1};

[Gx, midiVel, ~, ~, refVelCompare, ~, ~,~,~, gainCompare] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter);




%%
fileName = 'Beethoven_Op027No1-02_003_20090916-SMD';
audioFilename = strcat(fileName, '.mp3');
MIDIFilename = strcat(fileName, '.mid');

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 10;
basicParameter.updateBnumber = 50;
basicParameter.alpha1 = 10;
basicParameter.alpha2 = 0.1;
basicParameter.alpha3 = 1;
basicParameter.beta1= 1;
basicParameter.beta2= 1;
basicParameter.multiRankHopFrame = 1;
basicParameter.softConstraint = true;

basicParameter.fExtSecond = 0;
basicParameter.bExtSecond = 0.2;

B = initializeWwithHarmonicConstraint(basicParameter);

[Gx] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter);

%%

fileName = 'Beethoven_Op027No1-03_003_20090916-SMD';
audioFilename = strcat(fileName, '.mp3');
MIDIFilename = strcat(fileName,'_sync.mid');

nmat= readmidi_java(strcat(fileName, '.mid'),'true');


basicParameter = basicParameterInitialize;
basicParameter.rankMode = 5;
basicParameter.spectrumMode = 2;
basicParameter.basisSource = 'data';
basicParameter.updateBnumber = 5;
basicParameter.GpreUpdate = 20;
basicParameter.alpha1 = 5;
basicParameter.alpha2 = 1;
basicParameter.alpha3 = 1;
basicParameter.beta1= 1;
basicParameter.beta2= 1;
basicParameter.multiRankHopFrame = 1;
basicParameter.softConstraint = true;
basicParameter.bExtSecond = 0.4;
basicParameter.fExtSecond = 0.4;
basicParameter.usePseudoAligned = true;
% basicParameter.targetMedian =40;
% basicParameter.targetRange = 15;
% basicParameter.targetMedian = median(nmat(:,5));
% basicParameter.targetRange = std(nmat(:,5)) * sqrt(2);


B= Bscale;
% B = initializeWwithHarmonicConstraint(basicParameter);
% B = Bcell{1,2};
% basicParameter.fittingArray = ones(2,88);
basicParameter.fittingArray = fittingArrayCell{1,2};

% basicParameter = getDynamicRange('/Users/Da/Dropbox/midiVelocityResult/R5S2BdUbn5Gpr20aa5Uib.mat', basicParameter,16,21);

[G, midiVel, error] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter);

%%

fid = fopen('Beethoven_Op027No1-02_003_20090916-SMD_corresp.txt', 'r');
midiAlignResult = textscan(fid, '%s', 'delimiter', '\t');

midiAlignResult = reshape(midiAlignResult{1}, [10,length(midiAlignResult{1})/10])';

midiAligned = midiMatAlign(midiVel, midiAlignResult);





errorMatrix = zeros(length(midiVel),3);

for i = 1: length(midiVel)
    errorMatrix(i,1) = midiAligned(i,4);
    errorMatrix(i,2) = abs(midiAligned(i,5) - midiVel(i,5));% / midiRef(i,5);
    errorMatrix(i,3) = abs(midiAligned(i,5) - midiVel(i,5)) / midiAligned(i,5);
end

errorMatrix(find(errorMatrix(:,1)==0) , :) =[];
errorAbs = sum(errorMatrix(:,2)) / length(errorMatrix); % error
errorRel = sum(errorMatrix(:,3)) / length(errorMatrix);
errorAbsSTD =std(errorMatrix(:,2));
errorRelSTD = std(errorMatrix(:,3));

%%


basicParameter = basicParameterInitialize;
basicParameter.rankMode = 5;
basicParameter.spectrumMode = 2;
basicParameter.basisSource = 'data';
basicParameter.updateBnumber = 5;
basicParameter.GpreUpdate = 10;
basicParameter.alpha1 = 1;
basicParameter.alpha2 = 1;
basicParameter.alpha3 = 1;
basicParameter.beta1= 1;
basicParameter.beta2= 1;
basicParameter.multiRankHopFrame = 1;
basicParameter.softConstraint = true;

[GxGpr10Ubn5, ~, ~, ~, ~, ~, ~, B] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter);

%%

t1 = 1;
t2 = 500;
p1 = 10;
p2 = 60;

subplot(2,1,1)
imagesc(Gx( (p1-1)*basicParameter.rankMode+2:(p2-1)*basicParameter.rankMode+2,t1:t2))
axis xy


subplot(2,1,2)
imagesc(GxGpr10Ubn5( (p1-1)*basicParameter.rankMode+2:(p2-1)*basicParameter.rankMode+2,t1:t2))
axis xy
%%
subplot(2,1,2)
imagesc(softConstraintMatrix( (p1-1)*basicParameter.rankMode+2:(p2-1)*basicParameter.rankMode+2,t1:t2))
axis xy

%%
option = [];
option.saveMIDI = true;
option.audioToAudio = false;
option.calError = false;
option.audioExtension = 'mp3';
option.audioGTname = '_score';
option.midiGTname = '_score';
option.midiAdditionalName = '_sync';
option.useMIDI = false; 
option.useChroma = false;
option.sampleRate = 100;
option.dataMatchType = 'onePair';

alignFolder_VerChromaPy2(pwd, option );