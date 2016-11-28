function [sheetMatrix, minNote, maxNote, nmat] = makeSheetMatrixAS(MIDIFilename, basicParameter, Y, velPerNote, secPerNote)


% Rewrite MIDI with fixed times
nmat = readmidi_java(MIDIFilename,true);
nmat(:,7) = nmat(:,6) + nmat(:,7);
noteArray = unique(nmat(:,4));

minNote = min(noteArray);
maxNote = max(noteArray);

sheetMatrix = zeros(maxNote * 2 - minNote + 1, length(Y));
%sheetMatrix = zeros(maxNote , floor(nmat(length(nmat), 7) * 44100/nfft));


for i = 1: length(Y)
   timeSecond = (i+1) * basicParameter.nfft / basicParameter.sr;
   noteNumber = floor(timeSecond/velPerNote/secPerNote);
   meanVolume = mean(sum(Y(:,i)));

   if mod(timeSecond, secPerNote) <= secPerNote * 0.1
        sheetMatrix (noteNumber * 2 + minNote, i) = meanVolume;
   else if mod(timeSecond, secPerNote) <= secPerNote * 0.8
        %rmsVolume = abs(sqrt(sum(Y(:,i) .^2)));
        sheetMatrix (noteNumber * 2 + 1 + minNote, i) = meanVolume;
            %sheetMatrix (noteNumber+minNote, i) = rmsVolume;
            %sheetMatrix(noteNumber + minNote, i) = 1;
       else 
        sheetMatrix(minNote-1, i) = meanVolume;

           
           
   end
end



% for j = 1 :size(sheetMatrix,2)
%     if sum(sheetMatrix(:,j)) == 0
%         sheetMatrix(minNote-1, j) = 1;
%     end
% end

end
