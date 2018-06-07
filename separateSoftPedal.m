function [woPedal, wPedal] = separateSoftPedal(midiMat, pedalMat, threshold, estimatedVel)
    if size(midiMat,2) ==8
        midiMat(:,8) =[];
    end
%     woPedal = zeros(size(midiMat));
%     wPedal =  zeros(size(midiMat));
    wPedal = [];
    woPedal = [];
    for i = 1:size(midiMat,1)
        onset=midiMat(i,6);

        lastIndex = max(find(pedalMat(:,1) < onset));
        pedalOn = pedalMat(lastIndex, 2) > threshold;
        numSimulOnset =calNumberOfSimultaneousOnset(midiMat(i,:), midiMat);
        if pedalOn
            wPedal(size(wPedal,1)+1, 1:7) = midiMat(i,:);
            wPedal(size(wPedal,1), 8) = estimatedVel(i);
            wPedal(size(wPedal,1), 9) = numSimulOnset;
        else
            woPedal(size(woPedal,1)+1,1:7) = midiMat(i,:);
            woPedal(size(woPedal,1),8) = estimatedVel(i);
            woPedal(size(woPedal,1),9) = numSimulOnset;
            
%             woPedal(i,1:8) = midiMat(i,:);
        end
    end


end



function numSimulOnset =calNumberOfSimultaneousOnset(note, midiMat)
    threshold = 0.1;
%     numSimulOnset = sum( (abs(midiMat(:,6)-note(6)) < threshold) .* (midiMat(:,5) ~= note(5))  );
    numSimulOnset = sum(abs(midiMat(:,6)-note(6)) < threshold)  ;

end
