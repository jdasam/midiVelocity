function sheetMatrix = midi2MatrixOption(nmat, specLength, basicParameter, attackOnly, weightOnAttack)
    

    if nargin < 4
       attackOnly = false; 
    end
    if nargin < 5
        weightOnAttack = false;
    end
    
    attMargin = ceil(basicParameter.attackLengthSecond / basicParameter.nfft * basicParameter.sr);
%     attMargin = basicParameter.attackLengthFrame - 1;    
    if weightOnAttack
        weightMatrix = ones(1,attMargin*2+1);
        weightMatrix(1:attMargin1) = linspace(3,10,attMargin+1);
        weightMatrix(attMargin+1:end) = linspace(10,3,attMargin+1);
    end
    
    minNote = basicParameter.minNote;
    maxNote = basicParameter.maxNote;

    
    if basicParameter.rankMode == 2 % Two basis per Key, Attack and Sustain
        sheetMatrix = zeros( (maxNote - minNote + 1) *2 + 1, specLength);
    elseif basicParameter.rankMode == 3
        sheetMatrix = zeros( (maxNote - minNote + 1) *3 + 1, specLength);
    else % One basis per key
        sheetMatrix = zeros(maxNote-minNote + 2, specLength);

    end
          
    for i = 1 : length(nmat)
        attMargin = ceil(basicParameter.attackLengthSecond / basicParameter.nfft * basicParameter.sr);
%         attMargin = basicParameter.attackLengthFrame - 1;  
        basisIndex = nmat(i,4) - minNote + 2;
        onset = onsetTime2frame(nmat(i,6), basicParameter);
        if isfield(basicParameter, 'fExt')
            if basicParameter.fExt
                onset = onset - basicParameter.fExt;
                if onset < 1
                    onset = 1;
                end 
            end
        end
        
        if attackOnly
            if basicParameter.attackExceptRange
                offset = onset+ceil(basicParameter.attackExceptRange / basicParameter.nfft * basicParameter.sr);
            else    
                offset = onset+attMargin+basicParameter.offsetFine;
            end
        else
            offset = ceil( (nmat(i,7) * basicParameter.sr) / basicParameter.nfft) + basicParameter.offsetFine;
            if isfield(basicParameter, 'bExt')
                if basicParameter.bExt
                    offset = offset + basicParameter.bExt;
                end
            end
        end
            

        if offset > specLength
           offset = specLength; 
        end
        

        if basicParameter.rankMode == 2
            sheetMatrix(basisIndex, onset:offset) = 1;
            onset = onsetTime2frame(nmat(i,6), basicParameter);
            if onset+attMargin > offset
                attMargin = offset-onset;
            end
            sheetMatrix(basisIndex + (maxNote - minNote +1) , onset:onset+attMargin) = 1;
        elseif basicParameter.rankMode == 3
            searchRangeFrame = ceil(basicParameter.searchRange / basicParameter.nfft * basicParameter.sr);
            sheetMatrix(basisIndex, onset: min(onset+searchRangeFrame, offset)) = 1;
            if onset+attMargin > offset
                attMargin = offset-onset;
            end
            sheetMatrix(basisIndex + (maxNote - minNote +1) , onset:onset+attMargin) = 1;            
            if onset+basicParameter.searchRange < offset
                sheetMatrix(basisIndex + (maxNote - minNote +1) * 2, onset+searchRangeFrame+1:offset) = 1;
            end
            
        
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
    
    if basicParameter.rankMode == 2 & attackOnly
       sheetMatrix= sheetMatrix(1:maxNote-minNote + 2,:);
    end
    
end