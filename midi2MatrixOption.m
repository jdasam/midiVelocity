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
        sheetMatrix = zeros(maxNote * 2 - minNote + 1, specLength);
    else % One basis per key
        sheetMatrix = zeros(maxNote, specLength);
    end
          
    for i = 1 : length(nmat)
        notePitch = nmat(i,4);
        onset = onsetTime2frame(nmat(i,6), basicParameter);

        if attackOnly
            offset = onset+basicParameter.attackLengthFrame-1;
        else
            offset = ceil( nmat(i,7) * basicParameter.sr / basicParameter.nfft) -1;
        end

        if offset > specLength
           offset = specLength; 
        end
       

        if basicParameter.rankMode == 2
            sheetMatrix(notePitch * 2 - minNote, onset:offset) = 1;
            sheetMatrix(notePitch * 2 - minNote + 1, onset:onset+attMargin) = 1;
        else
            sheetMatrix(notePitch, onset:offset) = 1;
        end
        
        if weightOnAttack
            if basicParameter.rankMode == 2
                sheetMatrix(notePitch * 2 - minNote, onset:onset+attMargin*2) = weightMatrix;
%                 if onset > attMargin
%                     sheetMatrix(notePitch * 2 - minNote, onset-attMargin:onset+attMargin) = weightMatrix;
%                     sheetMatrix(notePitch * 2 - minNote + 1, onset-attMargin:onset+attMargin) = weightMatrix;
% 
%                 else
%                     sheetMatrix(notePitch * 2 - minNote, onset:onset+attMargin) = weightMatrix(attMargin+1:end);
%                 end
            else
                sheetMatrix(notePitch, onset:onset+attMargin*2) = weightMatrix;
%                 if onset > attMargin
%                     sheetMatrix(notePitch, onset-attMargin:onset+attMargin) = weightMatrix;
%                 else
%                     sheetMatrix(notePitch, onset:onset+attMargin) = weightMatrix(attMargin+1:end);
%                 end
            end

        end
        
        %sheetMatrix (notePitch, onset+1:onset+4) = 2 ^ (nmat(i,5)/15);
    end

    
    % if there is no note in the column, fill it with noise basis
    for j = 1 :size(sheetMatrix,2)
        if sum(sheetMatrix(:,j)) == 0
            sheetMatrix(minNote-1, j) = 1;
        end
    end

    % if the sheetMatrix size is longer than audio, delete the end of sheetMatrix
    if size(sheetMatrix,2) > specLength
       sheetMatrix(:,specLength+1:end) = []; 
    end
end