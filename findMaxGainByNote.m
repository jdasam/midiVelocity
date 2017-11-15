function [gainCalculated, maxIndex, onset, offset] = findMaxGainByNote(midiNote, G, basicParameter)

basisIndex = midiNote(4) - basicParameter.minNote +2;

index = onsetTime2frame(midiNote(6),basicParameter);
offset = ceil( (midiNote(7) * basicParameter.sr) / basicParameter.nfft) + basicParameter.offsetFine;

if isfield(basicParameter, 'bExt')
    if basicParameter.bExt
        offset = offset+basicParameter.bExt;
    end
end

if offset > size(G,2)
    offset = size(G,2);
end
searchRangeFrame = ceil(basicParameter.searchRange / basicParameter.nfft * basicParameter.sr);
indexEnd = index + searchRangeFrame;

if indexEnd > offset
indexEnd = offset;
end

if indexEnd > size(G,2)
indexEnd = size(G,2);
end


if isfield(basicParameter, 'fExt')
    [gainCalculated, onset] = max(G(basisIndex, max(index-basicParameter.fExt,1):indexEnd));
    maxIndex= onset;
    onset = onset + max(index-basicParameter.fExt,1)+ 1;
else
    [gainCalculated, onset] = max(G(basisIndex, index:indexEnd));
    maxIndex= onset;
    onset = onset + index +1;
end




if isfield(basicParameter, 'threshold')
    offsetNew = min(find(G(basisIndex, index+maxIndex:offset) < basicParameter.threshold)) + index + maxIndex - 1;
    
    if offsetNew
        offset = offsetNew;
    end
end



end