function [gainCalculated, maxIndex] = findMaxGainByNote(midiNote, G, basicParameter)

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


end