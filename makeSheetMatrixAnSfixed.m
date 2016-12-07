function [sheetMatrix] = makeSheetMatrixAnSfixed(basicParameter, Y)



sheetMatrix = midi2Matrix(basicParameter.MIDI, length(Y), basicParameter);

%sheetMatrix = zeros(maxNote * 2 - minNote + 1, length(Y));
%sheetMatrix = zeros(maxNote , floor(nmat(length(nmat), 7) * 44100/nfft));




% 
% for i = 1 : length(nmat)
%     notePitch = nmat(i,4);
%     sampleIndex = nmat(i,6) * basicParameter.sr;
%     if sampleIndex < basicParameter.window/2
%         onset = 1;
%     else
%         onset = ceil( ( sampleIndex - basicParameter.window /2 )/ basicParameter.nfft);
%     end
%     offset = ceil( nmat(i,7) * basicParameter.sr / basicParameter.nfft) + 1;
%     
%     sheetMatrix (notePitch * 2 - minNote, onset:offset) = 1;
%     sheetMatrix (notePitch * 2 - minNote + 1, onset:onset+basicParameter.attackLengthFrame-1) = 1;
%     %sheetMatrix (notePitch, onset+1:onset+4) = 2 ^ (nmat(i,5)/15);
% end
% 
% for j = 1 :size(sheetMatrix,2)
%     if sum(sheetMatrix(:,j)) == 0
%         sheetMatrix(minNote-1, j) = 1;
%     end
% end




% for j = 1 :size(sheetMatrix,2)
%     if sum(sheetMatrix(:,j)) == 0
%         sheetMatrix(minNote-1, j) = 1;
%     end
% end

end
