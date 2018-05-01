txtList = getFileListWithExtension('*_corresp.txt');
errorAndOmittedNotes = zeros(5, length(txtList));
%
for i = 1:length(txtList)
    txtFileName = strcat(txtList{i},'.txt');
    [errorAndOmittedNotes(1,i), errorAndOmittedNotes(2,i), errorAndOmittedNotes(3,i), errorAndOmittedNotes(4,i), errorAndOmittedNotes(5,i),  errorAndOmittedNotes(6,i)] = calMidiSyncErrorAndDiff(txtFileName);
    
end


%%

nmat= readmidi_java('Haydn_HobXVINo52-01_008_20110315-SMD_sync.mid');