function [meanSyncError, missedNotesNum, addedNotesNum, notatedRatio, under100ratio, fscore, missedNotesList, addedNotesList, alignedNotesNum] = calMidiSyncErrorAndDiff(txtFileName)

    fid = fopen(txtFileName, 'r');
    midiAlignResult = textscan(fid, '%s', 'delimiter', '\t');
    midiAlignResult = reshape(midiAlignResult{1}, [10,length(midiAlignResult{1})/10])';

% midiAlignResult = cell2mat(midiAlignResult);

% timeGT = cell2mat(midiAlignResult(:,2));
    timeGT = cellfun(@(x)str2double(x), midiAlignResult(:,2));
    timeAligned = cellfun(@(x)str2double(x), midiAlignResult(:,7));
    
    pitchGT = cellfun(@(x)str2double(x), midiAlignResult(:,4));
    pitchAligned = cellfun(@(x)str2double(x), midiAlignResult(:,9));
    
    addedNotes = timeAligned ==-1;
    missedNotes = timeGT==-1;


    timeGT_valid = timeGT(~ (addedNotes | missedNotes));
    timeAlinged_valid = timeAligned(~ (addedNotes | missedNotes));

    syncAbsError = abs(timeGT_valid - timeAlinged_valid);
    under100ratio = sum(syncAbsError<0.1) / length(syncAbsError);

    meanSyncError = mean(syncAbsError);
    missedNotesNum = sum(missedNotes);
    addedNotesNum = sum(addedNotes);
    alignedNotesNum = length(timeGT) - missedNotesNum - addedNotesNum;
    
    notatedRatio = alignedNotesNum / (length(timeGT) - missedNotesNum);
    playedRatio = alignedNotesNum / (length(timeAligned) - addedNotesNum);
    
    fscore = 2 * notatedRatio * playedRatio / (notatedRatio + playedRatio);
    
    missedNotesList = zeros(size(timeGT(timeGT<0),1),2);
    missedNotesList(:,1) = timeAligned(timeGT<0);
    missedNotesList(:,2) = pitchAligned(timeGT<0);
    
    addedNotesList = zeros(size(timeAligned(timeAligned<0),1),2);
    addedNotesList(:,1) = timeGT(timeAligned<0);
    addedNotesList(:,2) = pitchGT(timeAligned<0);
    
end