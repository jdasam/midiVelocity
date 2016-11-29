function [sheetMatrixTest, Gtest, Bcopy] = makeSheetMatrixTestAnS(sheetMatrix,Y, B, basicParameter)




nmat = basicParameter.MIDI;
sheetMatrixTest = zeros(size(sheetMatrix));
minNote = basicParameter.minNote;


for i = 1: length(Y)
   timeSecond = (i+1) * basicParameter.nfft / basicParameter.sr;
   noteNumber = floor(timeSecond/basicParameter.velMod/basicParameter.noteLength);
   meanVolume = mean(sum(Y(:,i)));

   if mod(timeSecond, basicParameter.noteLength) <= basicParameter.noteLength * 0.1
        sheetMatrixTest(noteNumber * 2 + 1 + minNote, i) = 1;
   end
   if mod(timeSecond, basicParameter.noteLength) <= basicParameter.noteLength * 0.8
        %rmsVolume = abs(sqrt(sum(Y(:,i) .^2)));
        sheetMatrixTest(noteNumber * 2 + minNote, i) = 1;
            %sheetMatrix (noteNumber+minNote, i) = rmsVolume;
            %sheetMatrix(noteNumber + minNote, i) = 1;
   else 
        sheetMatrixTest(minNote-1, i) = 1;
           
   end
end



% for i = 1 : length(nmat)
%     notePitch = nmat(i,4);
%     sampleIndex = nmat(i,6) * basicParameter.sr;
%     if sampleIndex < basicParameter.window/2
%         onset = 1;
%     else
%         onset = ceil( ( sampleIndex - basicParameter.window /2 )/ basicParameter.nfft) + 1;
%     end
%     offset = ceil( nmat(i,7) * basicParameter.sr / basicParameter.nfft) + 1;
%     
%     sheetMatrixTest (notePitch * 2 - basicParameter.minNote + 1, onset:offset) = 1;
%     sheetMatrixTest (notePitch * 2 - basicParameter.minNote + 1 , onset:onset+3) = 1;
%     %sheetMatrix (notePitch, onset+1:onset+4) = 2 ^ (nmat(i,5)/15);
% end
% 
% for j = 1 :size(sheetMatrixTest,2)
%     if sum(sheetMatrixTest(:,j)) == 0
%         sheetMatrixTest(basicParameter.minNote-1, j) = 1;
%     end
% end


Gtest = sheetMatrixTest(basicParameter.minNote-1:size(sheetMatrixTest,1),:);
Bcopy = B;
Bcopy = betaNormC(Bcopy,basicParameter.beta);

if size(Gtest,2) > size(Y,2)

    Gtest(:, length(Y) + 1 : length(Gtest) ) = [];

end



Xhat = Bcopy * Gtest;

betaDivergence = betaDivergenceMatrix(Y, Xhat, basicParameter.beta)


%Bcopy = Bcopy .* ((Y .* (Xhat .^(basicParameter.beta-2) ) * Gtest') ./ ((Xhat .^ (basicParameter.beta-1)) * Gtest'));
Gtest = Gtest .* ( Bcopy' * (Y .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))));

%Bcopy = betaNormC(Bcopy,basicParameter.beta);
%Bcopy = normc(Bcopy);
Bcopy(find(isnan(Bcopy)))=0;


Gtest(find(isnan(Gtest)))=0;
Xhat = Bcopy * Gtest;  
betaDivergence = betaDivergenceMatrix(Y, Xhat, basicParameter.beta)


 
for i = 1:15

    Gtest = Gtest .* ( Bcopy' * (Y .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))));
    Gtest(find(isnan(Gtest)))=0;
    
    Xhat = Bcopy * Gtest;
    betaDivergence = betaDivergenceMatrix(Y, Xhat, basicParameter.beta)
end

end