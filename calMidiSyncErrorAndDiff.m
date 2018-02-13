function [meanSyncError, missedNotesNum, addedNotesNum, notatedPercentage, under100ratio] = calMidiSyncErrorAndDiff(txtFileName)

    fid = fopen(txtFileName, 'r');
    midiAlignResult = textscan(fid, '%s', 'delimiter', '\t');
    midiAlignResult = reshape(midiAlignResult{1}, [10,length(midiAlignResult{1})/10])';

% midiAlignResult = cell2mat(midiAlignResult);

% timeGT = cell2mat(midiAlignResult(:,2));
    timeGT = cellfun(@(x)str2double(x), midiAlignResult(:,2));
    timeAligned = cellfun(@(x)str2double(x), midiAlignResult(:,7));

    addedNotes = timeAligned ==-1;
    missedNotes = timeGT==-1;


    timeGT_valid = timeGT(~ (addedNotes | missedNotes));
    timeAlinged_valid = timeAligned(~ (addedNotes | missedNotes));

    syncAbsError = abs(timeGT_valid - timeAlinged_valid);
    under100ratio = sum(syncAbsError<0.1) / length(syncAbsError);

    meanSyncError = mean(syncAbsError);
    missedNotesNum = sum(missedNotes);
    addedNotesNum = sum(addedNotes);
    
    notatedPercentage = ((length(timeGT) - missedNotesNum) - addedNotesNum) / (length(timeGT) - missedNotesNum);
    playedPercentage = ((length(timeGT) - missedNotesNum) - addedNotesNum) / (length(timeGT) - missedNotesNum);
end