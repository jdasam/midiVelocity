function [sheetMatrix, minNote, maxNote, nmat] = makeSheetMatrix(MIDIFilename, nfft, Y, velPerNote, secPerNote)


% Rewrite MIDI with fixed times
nmat = readmidi_java(MIDIFilename,true);
nmat(:,7) = nmat(:,6) + nmat(:,7);
noteArray = unique(nmat(:,4));

minNote = min(noteArray);
maxNote = max(noteArray);

sheetMatrix = zeros(maxNote, length(Y));
%sheetMatrix = zeros(maxNote , floor(nmat(length(nmat), 7) * 44100/nfft));


for i = 1: length(Y)
   timeSecond = i * nfft / 44100;
   noteNumber = floor(timeSecond/velPerNote/secPerNote);
   
   if mod(timeSecond,1) <= 0.8
        meanVolume = mean(sum(Y(:,i)));
        %rmsVolume = abs(sqrt(sum(Y(:,i) .^2)));
        if noteNumber < 108
            sheetMatrix (noteNumber+minNote, i) = meanVolume;
            %sheetMatrix (noteNumber+minNote, i) = rmsVolume;
            %sheetMatrix(noteNumber + minNote, i) = 1;
        end
   end
end

%

for j = 1 :size(sheetMatrix,2)
    if sum(sheetMatrix(:,j)) == 0
        sheetMatrix(minNote-1, j) = 1;
    end
end

end
