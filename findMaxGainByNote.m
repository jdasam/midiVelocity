function [gainCalculated, maxIndex, onset, offset, onsetClusterData] = findMaxGainByNote(midiNote, G, basicParameter, B)

if nargin < 4
    B = zeros(1,size(G,1));
end

onsetWindowSize = ceil(basicParameter.onsetWindowSecond * basicParameter.sr / basicParameter.nfft); %half of window

if midiNote(4) < 21
    gainCalculated = 0;
    maxIndex = 0;
    onset = 0;
    offset = 0;
    onsetClusterData =0;
    return 
end


if basicParameter.rankMode <= 2
    basisIndex = midiNote(4) - basicParameter.minNote +2;
else
    basisIndex = ( midiNote(4) - basicParameter.minNote ) * basicParameter.rankMode + 2;
    basisIndexEnd = basisIndex + basicParameter.rankMode - 1;

end

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
searchRangeFrame = ceil(basicParameter.searchRangeSecond / basicParameter.nfft * basicParameter.sr);
indexEnd = index + searchRangeFrame;

if indexEnd > offset
indexEnd = offset;
end

if indexEnd > size(G,2)
indexEnd = size(G,2);
end


onsetClusterData = [];

if isfield(basicParameter, 'fExt')
    if basicParameter.rankMode <= 2
        [gainCalculated, onset] = max(G(basisIndex, max(index-basicParameter.fExt,1):indexEnd));
    else
%         [gainCalculated, onset] = max((sum(B(:,basisIndex:basisIndexEnd).^basicParameter.spectrumMode * G(basisIndex:basisIndexEnd, max(index-basicParameter.fExt,1):indexEnd).^basicParameter.spectrumMode)).^(1/basicParameter.spectrumMode));
        [gainCalculated, onset] = max(sum(   (B(:,basisIndex+1:basisIndexEnd).^basicParameter.spectrumMode * G(basisIndex+1:basisIndexEnd, max(index-basicParameter.fExt,1):indexEnd).^basicParameter.spectrumMode) .^(1/basicParameter.spectrumMode)));
        clusterStartIndex = (index + onset -1) -(ceil(onsetWindowSize*0.5)-1) - basicParameter.fExt;
        clusterEndIndex = (index + onset -1) + (floor(onsetWindowSize*1.5)-1) - basicParameter.fExt;
        
%         if nargout == 5 && index + onset - basicParameter.fExt + 1 - onsetWindowSize > 0 && index + onset + onsetWindowSize <size(G,2) 
% %             onsetClusterData = G(basisIndex:basisIndexEnd, index + onset - basicParameter.fExt + 1 - 5 : index + onset - basicParameter.fExt + 5);
%             onsetClusterData = basicParameter.map_mx * B(:,basisIndex:basisIndexEnd) * G(basisIndex:basisIndexEnd, index + onset - basicParameter.fExt + 1 - onsetWindowSize : index + onset - basicParameter.fExt + onsetWindowSize);
%         end
%     end
%     maxIndex= onset;
%     onset = onset + max(index-basicParameter.fExt,1)+ 1;
    end
else
    if basicParameter.rankMode <= 2
        [gainCalculated, onset] = max(G(basisIndex, index:indexEnd));
    else
%         sourceSeparatedSpectrum = (B(:,basisIndex+1:basisIndexEnd) .^basicParameter.spectrumMode * G(basisIndex+1:basisIndexEnd, index:indexEnd).^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode);
        sourceSeparatedSpectrum = (B(:,basisIndex:basisIndexEnd) .^basicParameter.spectrumMode * G(basisIndex:basisIndexEnd, index:indexEnd).^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode);

        %         sourceSeparatedSpectrum = B(:,basisIndex+1:basisIndexEnd) * G(basisIndex+1:basisIndexEnd, index:indexEnd) ;
        [gainCalculated, onset]= max(sum (sourceSeparatedSpectrum));
%         [gainCalculated, onset] = max( (sum(  ( B(:,basisIndex:basisIndexEnd).^basicParameter.spectrumMode * G(basisIndex:basisIndexEnd, index:indexEnd).^basicParameter.spectrumMode) .^(1/basicParameter.spectrumMode));
%         [gainCalculated, onset] = max( sum((B(:,basisIndex+1:basisIndexEnd).^basicParameter.spectrumMode * G(basisIndex+1:basisIndexEnd, index:indexEnd).^basicParameter.spectrumMode) .^(1/basicParameter.spectrumMode)));
        
        clusterStartIndex = (index + onset) -(onsetWindowSize-1);
%         clusterStartIndex = (index + onset -1) -(onsetWindowSize-1);
        clusterEndIndex = (index + onset) + (onsetWindowSize);
    end
end
if basicParameter.rankMode > 2 && nargout == 5 && clusterStartIndex > 0 && clusterEndIndex <size(G,2)
%             onsetClusterData = G(basisIndex:basisIndexEnd, index + onset + 1 - 5 : index + onset + 5);
%             onsetClusterData = basicParameter.map_mx * B(:,basisIndex:basisIndexEnd) * G(basisIndex:basisIndexEnd, index + onset + 1 - onsetWindowSize : index + onset + onsetWindowSize);
    onsetClusterData = basicParameter.map_mx * B(:,basisIndex:basisIndexEnd) * G(basisIndex:basisIndexEnd, clusterStartIndex:clusterEndIndex);
end
maxIndex= onset;
onset = onset + index +1;




if isfield(basicParameter, 'threshold') && basicParameter.threshold
    offsetNew = min(find(G(basisIndex, index+maxIndex:offset) < basicParameter.threshold)) + index + maxIndex - 1;
    
    if offsetNew
        offset = offsetNew;
    end
end



end