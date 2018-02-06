function midiAligned = midiMatAlign(midiScore, alignResult)

midiAligned = zeros(size(midiScore));

for i=1:length(midiScore)
    candidateIndex = find(strcmp(alignResult(:,7),num2str(midiScore(i,6))));
    
    if length(candidateIndex) < 1
        continue
    end
    
    for j=1:length(candidateIndex)
        if strcmp(alignResult(candidateIndex(j),9), num2str(midiScore(i,4)) ) && ~strcmp(alignResult(candidateIndex(j), 2) , '-1')
            midiAligned(i,4) = str2double(alignResult(candidateIndex(j),4));
            midiAligned(i,5) = str2double(alignResult(candidateIndex(j),5));
            midiAligned(i,6) = str2double(alignResult(candidateIndex(j),2));
        end
        
    end
        
        
end


end
