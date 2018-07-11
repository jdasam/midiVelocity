function midi = matchMidiCorresp(midi, midiMatch)

    correspDouble = cellfun(@(x)str2double(x), midiMatch);
    
    
    for i = 1:size(midi,1)
        if correspDouble(i,7) ~= -1
            midi(i,9) = correspDouble(i,7) - midi(i,6);
        else
            midi(i,9) = NaN;
        end
    end
    

end