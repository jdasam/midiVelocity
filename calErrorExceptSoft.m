function [error, omittedNotesNum, omittedRatio] = calErrorExceptSoft(refVelCompare, midiname, txtname, basicParameter)
    
    midiMat = readmidi_java(midiname);
    midiMat(:,7) = midiMat(:,7) + midiMat(:,6);
    softBool = zeros(size(midiMat,1),1);
    

    pedalDouble = readPedalCsv(txtname);


    threshold = basicParameter.pedalThreshold;
    
  
    for i = 1:size(midiMat,1)
        onset = midiMat(i,6);


    %     pedalOnIndex = max(find(pedalDouble(:,1) < offset & pedalDouble(:,2)> threshold));
        lastIndex = max(find(pedalDouble(:,1) < onset));
        pedalOn = pedalDouble(lastIndex, 2) > threshold;
        if pedalOn
            softBool(i) = 1;
        end
    end
    softError = abs(refVelCompare(softBool==1,2) - refVelCompare(softBool==1,3));
    refVelCompare(softBool==1,:)=[];
    velError = abs(refVelCompare(:,2)-refVelCompare(:,3));
    error = [mean(velError), std(velError), mean(softError), std(softError)];
    
    omittedNotesNum = sum(softBool);
    includedNotesNum = length(refVelCompare);
    
    omittedRatio = omittedNotesNum/ (omittedNotesNum + includedNotesNum);
    
end