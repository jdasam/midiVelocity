function midiPedal = applyPedalTxt(midiMat, txtFilename, basicParameter)
    midiPedal = midiMat;    
    if ~basicParameter.usePedal
        return
    end

    fid = fopen(txtFilename, 'r');
    pedalInf = textscan(fid, '%s');
    pedalInfShape = reshape(pedalInf{1}, [2,length(pedalInf{1})/2])';
    pedalDouble = cellfun(@(x)str2double(x),pedalInfShape);



    threshold = basicParameter.pedalThreshold;
    for i = 1:size(midiMat,1)
        offset = midiMat(i,7);


    %     pedalOnIndex = max(find(pedalDouble(:,1) < offset & pedalDouble(:,2)> threshold));
        lastIndex = max(find(pedalDouble(:,1) < offset));
        pedalOn = pedalDouble(lastIndex, 2) > threshold;
        if pedalOn
            pedalOffIndex = min(find(pedalDouble(:,1) > offset & pedalDouble(:,2) < threshold));
            if pedalOffIndex
                newOffset = pedalDouble(pedalOffIndex, 1);
                midiPedal(i,7) = newOffset;
            end
        end
    end
end