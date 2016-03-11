function [sheetMatrixTest, Gtest, Bcopy] = makeSheetMatrixTest(sheetMatrix,Y, B, basicParameter)


nmat = basicParameter.MIDI;
sheetMatrixTest = zeros(size(sheetMatrix));



for i = 1 : length(nmat)
    notePitch = nmat(i,4);
    onset = ceil( nmat(i,6) * basicParameter.sr / basicParameter.nfft);
    offset = ceil( nmat(i,7) * basicParameter.sr / basicParameter.nfft);
    if onset < 1
        onset = 1;
    end
    sheetMatrixTest (notePitch, onset:offset) = 1;
    %sheetMatrix (notePitch, onset+1:onset+4) = 2 ^ (nmat(i,5)/15);
end

for j = 1 :size(sheetMatrixTest,2)
    if sum(sheetMatrixTest(:,j)) == 0
        sheetMatrixTest(basicParameter.minNote-1, j) = 1;
    end
end


Gtest = sheetMatrixTest(basicParameter.minNote-1:basicParameter.maxNote,:);
Bcopy = B;


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


 
for i = 1:3

    Gtest = Gtest .* ( Bcopy' * (Y .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))));
    Gtest(find(isnan(Gtest)))=0;
    
    Xhat = Bcopy * Gtest;
    betaDivergence = betaDivergenceMatrix(Y, Xhat, basicParameter.beta)
end

end