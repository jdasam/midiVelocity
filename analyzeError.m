function [totalError, totalNotes, errorBySimulCell, errorBySustCell, errorByVelCell, errorByPitchCell,errorByDoubleStrikeCell, errorByLengthCell, errorByNumNotesCell] = analyzeError(resultData, basicParameter, dir, compareData, semiAligned)

if nargin<3
    dir = pwd;
end

if nargin<4
%     compareData = false;
end

if nargin<5
    semiAligned = false;
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

errorName={'Simul', 'Sust', 'Vel', 'Pitch', 'DoubleStrike', 'Length', 'NumNotes', 'AlignErr', 'Added', 'Missed', 'Matched' };

for i = 1:length(errorName)
    eval(strcat('errorBy', errorName{i}, 'Cell = {};'))
end


totalError = zeros(127,length(errorName)*2);
totalNotes = zeros(1,length(errorName) + 1);

for i = 1:length(pieces)
    audioFilename = strcat(pieces{i}, '.mp3');
    MIDIFilename = strcat(pieces{i}, '.mid');
    scoreMIDIname = strcat(pieces{i}, '_aligned.mid');
    textFileName = strcat(pieces{i}, '_corresp.txt');
    pedalTxtFilename = strcat(pieces{i}, '_pedal.txt');

    for j = 1:length(resultData.title)
        if strcmp(resultData.title{j}, pieces{i}) == 1
            index = j;
            refVelCompare = resultData.compareRefVel{index};
            resultExist = true;
            break
        end
        
        if j ==length(resultData.title)
            resultExist = false;
        end
    end
    
    if ~resultExist
        continue
    end
    
    
    midiPiece = readmidi_java(MIDIFilename);
%     midiPiece(midiPiece(:,7)==0,:) = [];
    midiPiece(:,7) = midiPiece(:,6) + midiPiece(:,7);
    midiPiece = applyPedalTxt(midiPiece, pedalTxtFilename, basicParameter);
    
    specLength = ceil(midiPiece(end,7) * basicParameter.sr / basicParameter.nfft);
    tempParameter = basicParameter;
    tempParameter.rankMode = 1;
    sheetMidi = midi2MatrixOption(midiPiece, specLength, tempParameter);
    

    
    if exist(textFileName, 'file')
        midiScore = readmidi_java(scoreMIDIname);
        midiScore(midiScore(:,7)==0,:) = [];
        midiScore(:,7) = midiScore(:,6) + midiScore(:,7);
        midiScore = applyPedalTxt(midiScore, pedalTxtFilename, basicParameter);
        midiMatch = loadCorresp(textFileName);
        addedNotes = calAddedNotes(midiPiece, midiMatch);
        missedNotes = calMissedNotes(midiScore, midiMatch);
        if semiAligned
            refVelCompare = checkCorrespOrder(midiMatch, midiPiece, refVelCompare);
        end
    else
        continue
%         missedNotes = zeros(1,size(midiPiece,2));
%         addedNotes = zeros(1,size(midiPiece,2));
%         midiScore = zeros(1,size(midiPiece,2));
    end
    
   
    numSustainedNotesByFrame = sum(sheetMidi(2:end,:));
    
    if size(midiPiece,1) ~= size(refVelCompare,1)
%         refVelCompare = modifyRefVel(refVelCompare,textFileName);
        midiPiece(midiPiece(:,7)==midiPiece(:,6),:) = [];
    end     

    addedNotesSheet= midi2MatrixOption(addedNotes, specLength, tempParameter);
    missedNotesSheet = midi2MatrixOption(missedNotes, specLength, tempParameter);
    
    numAddedNotesByFrame =  sum(addedNotesSheet(2:end,:));
    numMissedNotesByFrame = sum(missedNotesSheet(2:end,:));
    
    midiPiece = matchMidiCorresp(midiPiece, midiMatch);
    
   
    
    for l = 1:length(errorName)
        eval(strcat('errorBy', errorName{l}, ' = zeros(127,2);' ))
    end
    
    if exist('compareData')
        for j = 1:length(compareData.title)
            if strcmp(compareData.title{j}, pieces{i}) == 1
                index = j;
                comparisonResult = compareData.compareRefVel{index};
                if length(comparisonResult) ~= length(refVelCompare)
                    compareData.title{j}
                end
                break
            end
        end
    end
    
    for k = 1:length(midiPiece)
        onsetFrame = ceil(midiPiece(k,6) * basicParameter.sr / basicParameter.nfft);
        numSimulOnset =calNumberOfSimultaneousOnset(midiPiece(k,:), midiPiece);
        numSustained = numSustainedNotesByFrame(onsetFrame);
        if exist('compareData')
            velError = abs(refVelCompare(k,2) -refVelCompare(k,3)) - abs(comparisonResult(k,2) - comparisonResult(k,3));
        else
            velError = abs(refVelCompare(k,2) -refVelCompare(k,3));
        end
        if refVelCompare(k,2) ==0 || refVelCompare(k,3) == 0
            continue
        end
        doubleStrikeCheck = calDobuleStrike(midiPiece(k,:), midiPiece);
        noteLength = min(round ( (midiPiece(k,7) - midiPiece(k,6)) * 50)+1, 127);
        numNotesInPiece = min(round (sum(midiPiece(:,4)==midiPiece(k,4)) /2)+1, 127);
        alignError = max(min(round(midiPiece(k,9) * 100), 63),-63) + 64;
        if strcmp(midiMatch{k,7}, '-1')
            matched =2;
        else
            matched =1;
        end
        
        errorBySimul = addError(errorBySimul, numSimulOnset, velError);
        errorBySust = addError(errorBySust, numSustained, velError);
        errorByVel = addError(errorByVel, midiPiece(k,5), velError);
        errorByPitch = addError(errorByPitch, midiPiece(k,4), velError);
        errorByDoubleStrike = addError(errorByDoubleStrike, doubleStrikeCheck, velError);
        errorByLength = addError(errorByLength,noteLength, velError);
        errorByNumNotes = addError(errorByNumNotes, numNotesInPiece, velError);
        errorByAlignErr = addError(errorByAlignErr, alignError, velError);
        errorByAdded = addError(errorByAdded, numAddedNotesByFrame(onsetFrame)+1, velError);
        errorByMissed = addError(errorByMissed, numMissedNotesByFrame(onsetFrame)+1, velError);
        errorByMatched = addError(errorByMatched, matched, velError);
        
        % noteInfo = [(1) pitch, (2) velocity (3) velocity error 
        % (4)simulOnset (5) sustained num (6) doubleStrike (7) noteLength
        % (8)note appearance (9)align error
        noteInfo = [midiPiece(k,4), midiPiece(k,5), refVelCompare(k,2)-refVelCompare(k,3), numSimulOnset, numSustained, doubleStrikeCheck, noteLength, numNotesInPiece, alignError,numAddedNotesByFrame(onsetFrame), numMissedNotesByFrame(onsetFrame),  matched ] ;
        if size(noteInfo,2) == size(totalNotes,2)
            totalNotes(size(totalNotes,1)+1,:) = noteInfo ;
        else
            continue
        end

        
    end
    
    for l=1:length(errorName)
        eval(strcat('totalError(:,', num2str(l*2-1), ':', num2str(l*2), ') = totalError(:,', num2str(l*2-1), ':', num2str(l*2), ')+ errorBy', errorName{l}, ';'))
    end
    

    
    for l=1:length(errorName)
        eval(strcat('errorBy', errorName{l}, '(:,1) = errorBy', errorName{l}, '(:,1) ./ errorBy', errorName{l}, '(:,2);'));
        eval(strcat('errorBy', errorName{l}, '(isnan(errorBy', errorName{l}, ')) = 0;'))
        eval(strcat('errorBy', errorName{l}, 'Cell{index} = errorBy', errorName{l}, ';'))
    end
    
end

for i = 1:length(errorName)
    
    totalError(:,i*2-1) = totalError(:,i*2-1) ./ totalError(:,i*2);
    
end


end 


function numSimulOnset =calNumberOfSimultaneousOnset(note, midiMat)
    threshold = 0.1;
%     numSimulOnset = sum( (abs(midiMat(:,6)-note(6)) < threshold) .* (midiMat(:,5) ~= note(5))  );
    numSimulOnset = sum(abs(midiMat(:,6)-note(6)) < threshold)  ;

end


function doubleStrikeCheck = calDobuleStrike(note, midiMat)
    threshold = 0.1;
    pitch = note(5);
    boolA =  midiMat(midiMat(:,5)==pitch,6) - note(6)  < threshold ;
    boolB = midiMat(midiMat(:,5)==pitch,6) - note(6) > 0 ;
    doubleStrikeCheck = sum(boolA & boolB) + 1;
end

function errorArray = addError(errorArray, index, error)
    
    errorArray(index, 1) = errorArray(index, 1) + error;
    errorArray(index, 2 ) =errorArray(index, 2) + 1;

end

function refVelCompare = modifyRefVel(refVelCompare, textFileName)

    fid = fopen(textFileName, 'r');
    midiAlignResult = textscan(fid, '%s', 'delimiter', '\t');
    midiAlignResult = reshape(midiAlignResult{1}, [10,length(midiAlignResult{1})/10])';
    fileName = strsplit(textFileName, '_corresp.txt');
    fileName = fileName{1};
    midiVel = readmidi_java(strcat(fileName, '_aligned.mid'));
    midiVel(:,5) = refVelCompare(:,3);
    
    [~, refVelCompare] = midiMatAlign(midiVel, midiAlignResult);       


end


function addedNotes = calAddedNotes(midiPerform, midiMatch)
    correspDouble = cellfun(@(x)str2double(x), midiMatch);
    addedNotesIndex = find(correspDouble(:,7) == -1);
    
    addedNotes = midiPerform(addedNotesIndex, :);

end

function missedNotes = calMissedNotes(midiScore, midiMatch)
    correspDouble = cellfun(@(x)str2double(x), midiMatch);
    missedNotesIndex = find(correspDouble(:,2) == -1);
    
     missedNotes = zeros(length(missedNotesIndex), size(midiScore,2)); 
    
    for i=1:length(missedNotesIndex)
        note = midiScore( abs(midiScore(:,6) - correspDouble(missedNotesIndex(i), 7))< 0.001 &  midiScore(:,4) == correspDouble(missedNotesIndex(i), 9),:);
        if isempty(note)
            note = zeros(1, size(midiScore,2));
        end
        missedNotes(i, :) = note;
        
    end
end



function compareRefVel = checkCorrespOrder(corresp, midi, compareRefVel)
    correspDouble = cellfun(@(x)str2double(x), corresp);
    emptyNotes = find(midi(:,2)==0);
    copmareRefVelBackup = compareRefVel;
    
    if ~isempty(emptyNotes)
         for i=1:length(emptyNotes)
            midi(emptyNotes(i),:) = [];
            if midi(emptyNotes(i),4) == compareRefVel(emptyNotes(i), 1)
                compareRefVel(emptyNotes(i),:) = [];
            else
                index=findFromCorresp(midi(emptyNotes(i),:), correspDouble);
                compareRefVel(index,:) = [];
            end
         end
    end
    
    
    for i = 1:length(midi)
        
        if correspDouble(i,4) ~= midi(i,4)
            index=findFromCorresp(midi(i,:), correspDouble);
            compareRefVel(i,:) = copmareRefVelBackup(index,:);
        end
    end
end


function index=findFromCorresp(midinote, correspDouble)
    
    candidateList = find( abs(correspDouble(:,2) - midinote(6)) < 0.001);

    for j=1:length(candidateList)
        % compare pitch, and check not missed
        if correspDouble(candidateList(j),4)  == midinote(4) 
            index= candidateList(j);
            return
        end
    end

    

end

