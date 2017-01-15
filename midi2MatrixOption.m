function sheetMatrix = midi2MatrixOption(nmat, specLength, basicParameter, attackOnly, weightOnAttack)
    
    if nargin < 4
       attackOnly = false; 
    end
    if nargin < 5
        weightOnAttack = false;
    end
    
    attMargin = basicParameter.attackLengthFrame - 1;    
    if weightOnAttack
        weightMatrix = ones(1,attMargin*2+1);
        weightMatrix(1:attMargin+1) = linspace(3,10,attMargin+1);
        weightMatrix(attMargin+1:end) = linspace(10,3,attMargin+1);
    end
    
    minNote = basicParameter.minNote;
    maxNote = basicParameter.maxNote;

    
    if basicParameter.rankMode == 2 % Two basis per Key, Attack and Sustain
        sheetMatrix = zeros( (maxNote - minNote + 1) *2 + 1, specLength);
    else % One basis per key
        sheetMatrix = zeros(maxNote-minNote + 2, specLength);
    end
          
    for i = 1 : length(nmat)
        attMargin = basicParameter.attackLengthFrame - 1;  
        basisIndex = nmat(i,4) - minNote + 2;
        onset = onsetTime2frame(nmat(i,6), basicParameter);

        if attackOnly
            offset = onset+attMargin+basicParameter.offsetFine;
        else
            offset = ceil( (nmat(i,7) * basicParameter.sr) / basicParameter.nfft) ;
        end

        if offset > specLength
           offset = specLength; 
        end
        

        if basicParameter.rankMode == 2
            sheetMatrix(basisIndex, onset:offset) = 1;
            if onset+attMargin > offset
                attMargin = offset-onset;
            end
            sheetMatrix(basisIndex + (maxNote - minNote +1) , onset:onset+attMargin) = 1;
        else
            sheetMatrix(basisIndex, onset:offset) = 1;
        end
        
        if weightOnAttack
            if onset+attMargin*2>offset
                sheetMatrix(basisIndex, onset:offset) = weightMatrix(1:offset-onset+1);
            else
                sheetMatrix(basisIndex, onset:onset+attMargin*2) = weightMatrix;
            end
        end
        
        %sheetMatrix (notePitch, onset+1:onset+4) = 2 ^ (nmat(i,5)/15);
    end

    
    % if there is no note in the column, fill it with noise basis
    for j = 1 :size(sheetMatrix,2)
        if sum(sheetMatrix(:,j)) == 0
            sheetMatrix(1, j) = 1;
        end
    end

    % if the sheetMatrix size is longer than audio, delete the end of sheetMatrix
    if size(sheetMatrix,2) > specLength
       sheetMatrix(:,specLength+1:end) = []; 
    end
end