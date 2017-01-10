function sheetMatrix = midi2Matrix(nmat, specLength, basicParameter)

    minNote = basicParameter.minNote;
    maxNote = basicParameter.maxNote;

    
    if basicParameter.rankMode == 2 % Two basis per Key, Attack and Sustain
        sheetMatrix = zeros(maxNote * 2 - minNote + 1, specLength);
    else % One basis per key
        sheetMatrix = zeros(maxNote, specLength);
    end
          
    for i = 1 : length(nmat)
        notePitch = nmat(i,4);
        sampleIndex = nmat(i,6) * basicParameter.sr;
        if sampleIndex < basicParameter.window/2
            onset = 1;
        else
            onset = ceil( ( sampleIndex - basicParameter.window /2 )/ basicParameter.nfft);
        end
        offset = ceil( nmat(i,7) * basicParameter.sr / basicParameter.nfft) -1;

        if offset > specLength
           offset = specLength; 
        end

        if basicParameter.rankMode == 2
            sheetMatrix(notePitch * 2 - minNote, onset:offset) = 1;
            sheetMatrix(notePitch * 2 - minNote + 1, onset:onset+basicParameter.attackLengthFrame-1) = 1;
        else
            sheetMatrix(notePitch, onset:offset) = 1;
        end
        %sheetMatrix (notePitch, onset+1:onset+4) = 2 ^ (nmat(i,5)/15);
    end

    for j = 1 :size(sheetMatrix,2)
        if sum(sheetMatrix(:,j)) == 0
            sheetMatrix(minNote-1, j) = 1;
        end
    end

    if size(sheetMatrix,2) > specLength
       sheetMatrix(:,specLength+1:end) = []; 
    end
end