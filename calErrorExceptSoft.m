function [error, omittedNotesNum] = calErrorExceptSoft(refVelCompare, midiname, txtname, basicParameter)
    
    midiMat = readmidi_java(midiname);
    midiMat(:,7) = midiMat(:,7) + midiMat(:,6);
    softBool = zeros(size(midiMat,1),1);
    

    fid = fopen(txtname, 'r');
    pedalInf = textscan(fid, '%s', 'Delimiter',',');
    pedalInfShape = reshape(pedalInf{1}, [2,length(pedalInf{1})/2])';
    pedalDouble = cellfun(@(x)str2double(x),pedalInfShape);



    threshold = basicParameter.pedalThreshold;
    
  
    for i = 1:size(midiMat,1)
        offset = midiMat(i,7);


    %     pedalOnIndex = max(find(pedalDouble(:,1) < offset & pedalDouble(:,2)> threshold));
        lastIndex = max(find(pedalDouble(:,1) < offset));
        pedalOn = pedalDouble(lastIndex, 2) > threshold;
        if pedalOn
            softBool(i) = 1;
        end
    end
    
    refVelCompare(softBool==1,:)=[];
    velError = abs(refVelCompare(:,2)-refVelCompare(:,3));
    error = [mean(velError), std(velError)];
    
    omittedNotesNum = sum(softBool);
    
end