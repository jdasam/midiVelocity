function [errorBySimulCell, errorBySustCell, errorByVelCell, totalError] = analyzeError(resultData, basicParameter, dir)

if nargin<3
    dir = pwd;
end

cd(dir);


mp3filesInFolder = getFileListWithExtension('*.mp3');
pieces = {}; % list of pieces
error = zeros(6, length(resultData.title));
numberOfNotesByError = zeros(127, length(resultData.title));

for i = 1:length(mp3filesInFolder)
    if length(strsplit(mp3filesInFolder{i}, '_score')) ==1
        pieces{length(pieces)+1} = mp3filesInFolder{i};
    end
end

errorBySimulCell = {};
errorBySustCell = {};
errorByVelCell = {};

totalError = zeros(127,6);

for i = 1:length(pieces)
    audioFilename = strcat(pieces{i}, '.mp3');
    MIDIFilename = strcat(pieces{i}, '.mid');
    textFileName = strcat(pieces{i}, '_corresp.txt');
    pedalTxtFilename = strcat(pieces{i}, '_pedal.txt');

    for j = 1:length(resultData.title)
        if strcmp(resultData.title{j}, pieces{i}) == 1
            index = j;
            refVelCompare = resultData.compareRefVel{index};
            break
        end
    end
    
    midiPiece = readmidi_java(MIDIFilename);
    midiPiece(:,7) = midiPiece(:,6) + midiPiece(:,7);
    midiPiece = applyPedalTxt(midiPiece, pedalTxtFilename, basicParameter);
    specLength = ceil(midiPiece(end,7) * basicParameter.sr / basicParameter.nfft);
    tempParameter = basicParameter;
    tempParameter.rankMode = 1;
    sheetMidi = midi2MatrixOption(midiPiece, specLength, tempParameter);
    numSustainedNotesByFrame = sum(sheetMidi(2:end,:));
    
    errorBySimul = zeros(127,2);
    errorBySust = zeros(127,2);
    errorByVel = zeros(127,2);
    
    for k = 1:length(midiPiece)
        onsetFrame = ceil(midiPiece(k,6) * basicParameter.sr / basicParameter.nfft);
        numSimulOnset =calNumberOfSimultaneousOnset(midiPiece(k,:), midiPiece);
        numSustained = numSustainedNotesByFrame(onsetFrame);
        velError = abs(refVelCompare(k,2) -refVelCompare(k,3));
        
        errorBySimul(numSimulOnset, 1) = errorBySimul(numSimulOnset, 1) + velError;
        errorBySimul(numSimulOnset, 2) = errorBySimul(numSimulOnset, 2) +1;
        errorBySust(numSustained, 1) = errorBySust(numSustained,1) + velError;
        errorBySust(numSustained, 2) = errorBySust(numSustained,2) + 1;
        errorByVel(midiPiece(k,5), 1) = errorByVel(midiPiece(k,5), 1) + velError;
        errorByVel(midiPiece(k,5), 2) = errorByVel(midiPiece(k,5), 2) + 1;

        
    end
    totalError(:,1:2) = totalError(:,1:2) + errorBySimul;
    totalError(:,3:4) = totalError(:,3:4) + errorBySust;
    totalError(:,5:6) = totalError(:,5:6) + errorByVel;
    
    
    errorBySimul(:,1) = errorBySimul(:,1) ./ errorBySimul(:,2);
    errorBySimul(isnan(errorBySimul)) =0;
    errorBySust(:,1) = errorBySust(:,1) ./ errorBySust(:,2);
    errorBySust(isnan(errorBySust)) =0;
    
    errorByVel(:,1) = errorByVel(:,1) ./ errorByVel(:,2);
    errorByVel(isnan(errorByVel)) = 0;
    
    errorBySimulCell{index} = errorBySimul;
    errorBySustCell{index} = errorBySust;
    errorByVellCell{index} = errorByVel;
    
end

totalError(:,1) = totalError(:,1) ./ totalError(:,2);
totalError(:,3) = totalError(:,3) ./ totalError(:,4);
totalError(:,5) = totalError(:,5) ./ totalError(:,6);

end 


function numSimulOnset =calNumberOfSimultaneousOnset(note, midiMat)
    threshold = 0.1;
%     numSimulOnset = sum( (abs(midiMat(:,6)-note(6)) < threshold) .* (midiMat(:,5) ~= note(5))  );
    numSimulOnset = sum(abs(midiMat(:,6)-note(6)) < threshold)  ;

end