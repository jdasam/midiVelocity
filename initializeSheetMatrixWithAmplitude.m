function initializedG = initializeSheetMatrixWithAmplitude(X, sheetMatrix, basicParameter)
    
    beta=basicParameter.beta;
    for i = 1:size(sheetMatrix,2)
        
       if sum(sheetMatrix(:,i)) == 1
           sheetMatrix(find(sheetMatrix(:,i)),i) = sum(X(:,i) .^ beta) ^ (1/beta);
       else
           sheetMatrix(min(find(sheetMatrix(:,i))),i) =  sum(X(:,i) .^ beta) ^ (1/beta);
       end
        
    end
    
    initializedG = sheetMatrix;
end