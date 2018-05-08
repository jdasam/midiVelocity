function [midiAligned, refVelCompare] = midiMatAlign(midiScore, alignResult)

midiAligned = zeros(size(midiScore));
refVelCompare = zeros(1,3);
    
for i=1:length(midiScore)
    candidateIndex = find(strcmp(alignResult(:,7),num2str(midiScore(i,6))));
    
    if length(candidateIndex) < 1
        continue
    end
    
    for j=1:length(candidateIndex)
        if strcmp(alignResult(candidateIndex(j),4), num2str(midiScore(i,4)) ) && ~strcmp(alignResult(candidateIndex(j), 2) , '-1')
            midiAligned(i,4) = str2double(alignResult(candidateIndex(j),4));
            midiAligned(i,5) = str2double(alignResult(candidateIndex(j),5));
            midiAligned(i,6) = str2double(alignResult(candidateIndex(j),2));
            
            refVelCompare(candidateIndex(j), 1) = str2double(alignResult(candidateIndex(j),4));
            refVelCompare(candidateIndex(j), 2) = str2double(alignResult(candidateIndex(j),5));
            refVelCompare(candidateIndex(j), 3) = midiScore(i,5);
        end
        
    end
end

lastIndex = size(refVelCompare,1)+1;
while lastIndex <= size(alignResult,1) && ~strcmp(alignResult(lastIndex, 1), '*')
    
    refVelCompare(lastIndex,1) =  str2double(alignResult(lastIndex,4));
    refVelCompare(lastIndex,2) =  str2double(alignResult(lastIndex,5));
    lastIndex = lastIndex +1;
end


end
