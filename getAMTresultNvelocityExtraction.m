function G = getAMTresultNvelocityExtraction(predict, audioFilename, B, basicParameter)


if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
    [X, basicParameter.sr] = audio2spectrogram(audioFilename, basicParameter);
    if strcmp(basicParameter.scale, 'midi')
    X = basicParameter.map_mx * X;
    end
elseif strcmp(basicParameter.scale, 'erbt')
    [X, f, alen] = audio2erbt(audioFilename, basicParameter);
end
fittingArray = basicParameter.fittingArray;


sheetMatrixMidi = predict(:,13:end)';
sheetMatrixMidi(sheetMatrixMidi < 0.5) = 0;
sheetMatrixMidi(sheetMatrixMidi >=0.5 ) = 1;
sheetMatrixMidi = [zeros(1, size(sheetMatrixMidi,2)); sheetMatrixMidi ];

if size(X,2) < size(sheetMatrixMidi,2)
    sheetMatrixMidi(:,size(X,2)+1:end) = [];
end
    
    


if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
    G = sheetMatrixMidi;

elseif strcmp(basicParameter.scale, 'erbt')
    sheetMatrixTotalCopy = sheetMatrixMidi(2:end,:);
    G = vertcat(sheetMatrixTotalCopy, sheetMatrixMidi(1,:));
end

if basicParameter.BpartialUpdate
    harmBoolean = initializeWwithHarmonicConstraint(basicParameter); 
    harmBoolean(harmBoolean>0) = 1;
end



if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')

    Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
    
    
    if basicParameter.GpreUpdate
       for i = 1:basicParameter.GpreUpdate
           G = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
           G(find(isnan(G)))=0;
           Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
       end
        
    end
    if isfield(basicParameter, 'transcription')
        if basicParameter.transcription
%             B = rand(size(X,1), size(G,1));
%             if basicParameter.harmConstrain
%                 B = initializeWwithHarmonicConstraint(basicParameter);
%             end
        end
    end

    for i = 1:50
        Bnew = B;
        Gnew = G;

        temporalConstraintDummy = zeros(size(G));
        Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter,temporalConstraintDummy);
        Gnew(find(isnan(Gnew)))=0;
        
        if i < basicParameter.updateBnumber
            if basicParameter.BpartialUpdate
                tempUpdate = (X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G') .* harmBoolean;
                tempUpdate(tempUpdate==0) = 1;
                Bnew = B .* tempUpdate;
                Bnew = betaNormC(Bnew,basicParameter.beta);
                Bnew(find(isnan(Bnew)))=0;
            else
%                 Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
                if basicParameter.rankMode == 2;
                    specCont = ([B(2:end,:) ; zeros(1, 177)] + [zeros(1, 177); B(1:end-1,:)] ).* [zeros(size(B,1), 89), ones(size(B,1),88)];
                    sigma = 0.5;
                    Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G'  + specCont * 2* sigma)   ./ ((Xhat .^ (basicParameter.beta-1)) * G' + 4*sigma*B.* [zeros(size(B,1), 89) ones(size(B,1),88)])); 
%                     Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));

                else
                    Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
                end

                
                Bnew = betaNormC(Bnew,basicParameter.beta);
                Bnew(find(isnan(Bnew)))=0;
            end
        end

        B=Bnew;
        G=Gnew;

        Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

        
    end
%     D = sum(betaDivergence(X, Xhat, basicParameter.beta))


elseif strcmp(basicParameter.scale, 'erbt')
    [G B] = erbtHarmclusNMF(X, G, B , 250,f,alen, basicParameter, false); 
    
    G = vertcat(G(end,:),G);
    G(end,:) = [];
end


end