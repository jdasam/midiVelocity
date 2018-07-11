function [midiAlignResult, timeGT, timeAligned, pitchGT, pitchAligned] = loadCorresp(txtFileName)

    fid = fopen(txtFileName, 'r');
    midiAlignResult = textscan(fid, '%s', 'delimiter', '\t');
    midiAlignResult = reshape(midiAlignResult{1}, [10,length(midiAlignResult{1})/10])';


    timeGT = cellfun(@(x)str2double(x), midiAlignResult(:,2));
    timeAligned = cellfun(@(x)str2double(x), midiAlignResult(:,7));
    
    pitchGT = cellfun(@(x)str2double(x), midiAlignResult(:,4));
    pitchAligned = cellfun(@(x)str2double(x), midiAlignResult(:,9));



end