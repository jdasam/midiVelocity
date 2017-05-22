function [gainCalculated, maxIndex, onset, offset] = findMaxGainByNote(midiNote, G, basicParameter)

basisIndex = midiNote(4) - basicParameter.minNote +2;

index = onsetTime2frame(midiNote(6),basicParameter);
offset = ceil( (midiNote(7) * basicParameter.sr) / basicParameter.nfft) + basicParameter.offsetFine;

indexEnd = index + basicParameter.searchRange;
if indexEnd > size(G,2)
indexEnd = size(G,2);
end

if indexEnd > offset
indexEnd = offset;
end


[gainCalculated, maxIndex] = max(G(basisIndex, index:indexEnd));
[~, onset] = max(G(basisIndex, max(index-40,1):indexEnd));
onset = onset + max(index-40,1)+ 1;



if isfield(basicParameter, 'threshold')
    offsetNew = min(find(G(basisIndex, index+maxIndex:offset+200) < basicParameter.threshold)) + index + maxIndex - 1;
    
    if offsetNew
        offset = offsetNew;
    end
end



end