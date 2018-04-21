function initializedG = initializeSheetMatrixWithAmplitude(X, sheetMatrix, basicParameter)
    
    beta=basicParameter.beta;
    for i = 1:size(sheetMatrix,2)
       energySum = sum(X(:,i) .^ beta) ^ (1/beta);
       numActivatedBasis = sum(sheetMatrix(:,i));
       if numActivatedBasis == 1
           sheetMatrix(find(sheetMatrix(:,i)),i) = energySum;
       elseif basicParameter.rankMode == 2 || basicParameter.ampInitialMode ==1
           sheetMatrix(min(find(sheetMatrix(:,i))),i) = energySum;
       elseif basicParameter.ampInitialMode == 2
           sheetMatrix(find(sheetMatrix(:,i)),i) = energySum / numActivatedBasis ;
       elseif basicParameter.ampInitialMode == 3
           sheetMatrix(find(sheetMatrix(:,i)),i) = energySum * sqrt(2) / numActivatedBasis ;
       end 
    end
    
    initializedG = sheetMatrix;
end