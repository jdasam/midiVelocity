function [G, midiVel, error, errorPerNoteResult, refVelCompare, maxIndexVector, histogramData, B, numberOfNotesByError] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter)

if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
    [X, basicParameter.sr] = audio2spectrogram(audioFilename, basicParameter);
    if strcmp(basicParameter.scale, 'midi')
    X = basicParameter.map_mx * X;
    end
elseif strcmp(basicParameter.scale, 'erbt')
    [X, f, alen] = audio2erbt(audioFilename, basicParameter);
end
fittingArray = basicParameter.fittingArray;



midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);
midiVel = midiRef;
basicParameter.MIDI = midiRef;

if isfield(basicParameter, 'fExtSecond')
    if basicParameter.fExtSecond
        basicParameter.fExt = ceil(basicParameter.fExtSecond / basicParameter.nfft * basicParameter.sr); % forward Extension
        basicParameter.bExt = ceil(basicParameter.bExtSecond / basicParameter.nfft * basicParameter.sr); % backward Extnsion
        basicParameter.attackLengthSecond = basicParameter.attackLengthSecond + basicParameter.fExtSecond;
    end
end

sheetMatrixMidi = midi2MatrixOption(midiRef, size(X,2), basicParameter, false, basicParameter.weightOnAttack);




% Rewrite MIDI with fixed times


% Calculate Gx
if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
    if isfield(basicParameter, 'softConstraint') && basicParameter.softConstraint
        G = rand(size(sheetMatrixMidi));
        softConstraintMatrix = sheetMatrixMidi;
        softConstraintMatrix(1,:) = 0;
    else
        G = sheetMatrixMidi;
        softConstraintMatrix = zeros(size(G));
    end

elseif strcmp(basicParameter.scale, 'erbt')
    sheetMatrixTotalCopy = sheetMatrixMidi(2:end,:);
    G = vertcat(sheetMatrixTotalCopy, sheetMatrixMidi(1,:));
end

if basicParameter.BpartialUpdate
    harmBoolean = initializeWwithHarmonicConstraint(basicParameter); 
    harmBoolean(harmBoolean>0) = 1;
end


[G, B] = NMFwithMatrix(G, B, X, basicParameter, basicParameter.iterationPiece, softConstraintMatrix);

% if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
% 
%     Xhat = (B.^basicParameter.sp  ectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
%     
%     
%     if basicParameter.GpreUpdate
%        for i = 1:basicParameter.GpreUpdate
%            Gnew =updateG(G, B, X, Xhat, basicParameter, softConstraintMatrix);
%            G = Gnew;
%            Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
%        end
%         
%     end
%     if isfield(basicParameter, 'transcription')
%         if basicParameter.transcription
% %             B = rand(size(X,1), size(G,1));
% %             if basicParameter.harmConstrain
% %                 B = initializeWwithHarmonicConstraint(basicParameter);
% %             end
%         end
%     end
% 
%     
%     for i = 1:50
%         Bnew = B;
%         Gnew = G;
% 
%         Gnew =updateG(G, B, X, Xhat, basicParameter, softConstraintMatrix);
%         
% %         Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
% %         Gnew(find(isnan(Gnew)))=0;
%         
%         if i < basicParameter.updateBnumber
%             if basicParameter.BpartialUpdate
%                 tempUpdate = (X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G') .* harmBoolean;
%                 tempUpdate(tempUpdate==0) = 1;
%                 Bnew = B .* tempUpdate;
%                 Bnew = betaNormC(Bnew,basicParameter.beta);
%                 Bnew(find(isnan(Bnew)))=0;
%             else
% %                 Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
%                 if basicParameter.rankMode == 2;
%                     specCont = ([B(2:end,:) ; zeros(1, 177)] + [zeros(1, 177); B(1:end-1,:)] ).* [zeros(size(B,1), 89), ones(size(B,1),88)];
%                     sigma = 0.5;
%                     Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G'  + specCont * 2* sigma)   ./ ((Xhat .^ (basicParameter.beta-1)) * G' + 4*sigma*B.* [zeros(size(B,1), 89) ones(size(B,1),88)])); 
% %                     Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
%                 elseif basicParameter.rankMode >3 ;
%                     Bnew = updateB(B, G, X, Xhat, basicParameter);
%                     
%                     
%                 else
%                     Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
%                 end
% 
%                 
%                 Bnew = betaNormC(Bnew,basicParameter.beta);
%                 Bnew(find(isnan(Bnew)))=0;
%             end
%         end
% 
%         B=Bnew;
%         G=Gnew;
% 
%         Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
% 
%         
%     end
% %     D = sum(betaDivergence(X, Xhat, basicParameter.beta))
% 
% 
% elseif strcmp(basicParameter.scale, 'erbt')
%     [G B] = erbtHarmclusNMF(X, G, B , 250,f,alen, basicParameter, false); 
%     
%     G = vertcat(G(end,:),G);
%     G(end,:) = [];
% end

if basicParameter.fittingArray(1,1)

    % evaluate the result
%     midiVel = readmidi_java(MIDIFilename,true);
%     midiVel(:,7) = midiVel(:,6) + midiVel(:,7);
    maxIndexVector = zeros(size(midiVel,1),1);
    gainFromVelVec = zeros(size(midiVel,1),1);
    gainCalculatedVec = zeros(size(midiVel,1),1);
    
    onsetClusterArray = {};
    onsetMatchedVel = [];
    
    histogramData = [];
    [histogramData.histData, histogramData.histMIDI, histogramData.f, histogramData.f2]= makeHistogram(MIDIFilename, G, basicParameter, B);
%     [~, ~, histogramData.f]= makeHistogram(MIDIFilename, G, basicParameter);

    if isfield(basicParameter, 'targetMedian') && basicParameter.targetMedian
%         tempG = (20*log10(G+eps) - histogramData.f.b1) *  ( (basicParameter.targetRange -basicParameter.dynRan(2))/basicParameter.dynRan(1)/histogramData.f.c1  ) + histogramData.f.b1;
%         G = 10.^(tempG/20);
%         [histogramData.histData, histogramData.histMIDI, histogramData.f, histogramData.f2]= makeHistogram(MIDIFilename, G, basicParameter);
%         targetGain = (basicParameter.targetMedian-basicParameter.dynMed(2))/basicParameter.dynMed(1);
% %         G = G .* 10 ^((targetGain - histogramData.f.b1)/20 );
%         G =  10.^ ((log10(G+eps) * 20 + (targetGain - histogramData.f.b1))/20);
        fittingArray(1,:) = histogramData.f.c1 /20 * log(10) / basicParameter.targetRange;
        fittingArray(2,:) = histogramData.f.b1 / 20 * log(10)  - histogramData.f.c1 /20 * log(10) / basicParameter.targetRange * basicParameter.targetMedian;
        
    end
    
    
    if isfield(basicParameter, 'usePseudoAligned') && basicParameter.usePseudoAligned
        fileName = strsplit(audioFilename, '.mp3');
        fileName = fileName{1};
        fid = fopen(strcat(fileName, '_corresp.txt'), 'r');
        midiAlignResult = textscan(fid, '%s', 'delimiter', '\t');

        midiAlignResult = reshape(midiAlignResult{1}, [10,length(midiAlignResult{1})/10])';

        midiRef = midiMatAlign(midiVel, midiAlignResult);

        
        
        
    end

    for i = 1:length(midiVel)
        
        basisIndex = max(midiVel(i,4),21) - basicParameter.minNote + 2;

        [gainCalculated, maxIndex, ~, ~, onsetCluster] = findMaxGainByNote(midiVel(i,:), G, basicParameter, B);
        
      
        maxIndexVector(i) = maxIndex;
        if basisIndex == 1
            coefA = fittingArray(1, 1);
            coefB = fittingArray(2, 1);
        else
            
            coefA = fittingArray(1, basisIndex-1);
            coefB = fittingArray(2, basisIndex-1);
        end

%         logGainFromVel = exp(midiVel(i,5) * coefA + coefB);
        logGainFromVel = exp(midiRef(i,5) * coefA + coefB);
        

        midiVel(i,5) = round(  ( log(gainCalculated) - coefB ) / coefA);    
        gainFromVelVec(i) = logGainFromVel ^0.6;
        gainCalculatedVec(i) = gainCalculated ^0.6;
        %midiVel(i,5) = round(sqrt(max(Gx(pitch,index:index))) * 2.5);
        if midiVel(i,5) < 0
            midiVel(i,5) = 1;
        end
        if midiVel(i,5) > 127
            midiVel(i,5) = 127;
        end
                
        %save onset Cluster data
        if midiRef(i,5) ~= 0 && length(onsetCluster)
            onsetClusterArray{length(onsetClusterArray)+1} = onsetCluster;
            onsetMatchedVel(length(onsetMatchedVel)+1) = midiRef(i,5);
        end

    end
    % calculate error
    [error, errorPerNoteResult, refVelCompare, numberOfNotesByError] = calculateError(midiRef, midiVel, gainFromVelVec, gainCalculatedVec);
%     save('onsetCluster.mat', 'onsetClusterArray', 'onsetMatchedVel')
    midiVel(:,7) = midiVel(:,7) - midiVel(:,6);

    %plot(betaDivVector)
    
else
    error =0;
    errorPerNoteResult =0;
    refVelCompare =0;
    histogramData =0;
    maxIndexVector = 0;
end

if isfield(basicParameter, 'transcription')
    Gsheet= G;
    Bsheet= B;        

    if basicParameter.transcription
%         G = rand(size(Gsheet));
%         
%         Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
% 
%         
% 
%         for i = 1:50
%             
%             Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, temporalConstraintDummy);
%             Gnew(find(isnan(Gnew)))=0;
%             G=Gnew;
%             specCont = ([B(2:end,:) ; zeros(1, 177)] + [zeros(1, 177); B(1:end-1,:)] ).* [zeros(size(B,1), 89), ones(size(B,1),88)];
%             sigma = 0.5;
%             Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G'  + specCont * 2* sigma)   ./ ((Xhat .^ (basicParameter.beta-1)) * G' + 4*sigma*B.* [zeros(size(B,1), 89) ones(size(B,1),88)])); 
%             Bnew = betaNormC(Bnew,basicParameter.beta);
%             Bnew(find(isnan(Bnew)))=0;
%             B= Bnew;
% 
%             
%             Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
% 
%         end
%        
% 
% 
% %         for i = 1:length(midiVel)
% %             basisIndex = midiVel(i,4) - basicParameter.minNote + 2;
% % 
% %             [gainCalculated, maxIndex, onset, offset] = findMaxGainByNote(midiVel(i,:), G, basicParameter);
% %             midiVel(i,6) = onset * basicParameter.nfft / basicParameter.sr;
% %             midiVel(i,7) = offset * basicParameter.nfft / basicParameter.sr;
% % 
% %         end
% 
%         Grand = G;
%         Brand = B;
%         B = Bsheet;
%     
%         
%         basicAlt = basicParameter;
%         basicAlt.fExt = 100;
%         basicAlt.bExt = 100;
%         basicAlt.attackLengthFrame = basicParameter.attackLengthFrame - basicAlt.onsetFine;
% 
%         G =  midi2MatrixOption(midiRef, size(X,2), basicAlt, false, false);
%         
%         Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
% 
%  
%         for i = 1:50
%             Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, temporalConstraintDummy);
%             Gnew(find(isnan(Gnew)))=0;
%             G=Gnew;
%             specCont = ([B(2:end,:) ; zeros(1, 177)] + [zeros(1, 177); B(1:end-1,:)] ).* [zeros(size(B,1), 89), ones(size(B,1),88)];
%             sigma = 0.5;
%             Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G'  + specCont * 2* sigma)   ./ ((Xhat .^ (basicParameter.beta-1)) * G' + 4*sigma*B.* [zeros(size(B,1), 89) ones(size(B,1),88)])); 
%             Bnew = betaNormC(Bnew,basicParameter.beta);
%             Bnew(find(isnan(Bnew)))=0;
%             B= Bnew;
% 
%             
%             Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
% 
%         end
%         Ghyb = G;
%         Bhyb = B;
%         
%         
%         
%         
%         B = Bsheet;       
%         G =  rand(size(Gsheet));
%         
%         Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
% 
%  
%         for i = 1:50
%             Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, temporalConstraintDummy);
%             Gnew(find(isnan(Gnew)))=0;
%             G=Gnew;
%             
%             Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
% 
%         end
%              
%         Ghyb2 = G;
%         Bhyb2 = B;
%         
%         
%         B = initializeWwithHarmonicConstraint(basicParameter);
%         G =  midi2MatrixOption(midiRef, size(X,2), basicParameter, false, false);
%         Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
% 
%  
%         for i = 1:50
%             Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, temporalConstraintDummy);
%             Gnew(find(isnan(Gnew)))=0;
%             G=Gnew;
%             Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
%             Bnew = betaNormC(Bnew,basicParameter.beta);
%             Bnew(find(isnan(Bnew)))=0;
%             B= Bnew;
%             
%             Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
% 
%         end
%              
%         Ghyb3 = G;
%         Bhyb3 = B;
%         
%         
%         
        B = initializeWwithHarmonicConstraint(basicParameter);
        G = rand(size(Gsheet));
        
        Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
        for i = 1:50
            
            Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
            Gnew(find(isnan(Gnew)))=0;
            G=Gnew;
            specCont = ([B(2:end,:) ; zeros(1, 177)] + [zeros(1, 177); B(1:end-1,:)] ).* [zeros(size(B,1), 89), ones(size(B,1),88)];
            sigma = 0.5;
            Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G'  + specCont * 2* sigma)   ./ ((Xhat .^ (basicParameter.beta-1)) * G' + 4*sigma*B.* [zeros(size(B,1), 89) ones(size(B,1),88)])); 
            Bnew = betaNormC(Bnew,basicParameter.beta);
            Bnew(find(isnan(Bnew)))=0;
            B= Bnew;

            
            Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

        end
        
        Brand2 = B;
        Grand2 = G;

        
        B = extrapolate(Bsheet);
        G = rand(size(Gsheet));
        
        Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
        for i = 1:50
            
            Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
            Gnew(find(isnan(Gnew)))=0;
            G=Gnew;
            specCont = ([B(2:end,:) ; zeros(1, 177)] + [zeros(1, 177); B(1:end-1,:)] ).* [zeros(size(B,1), 89), ones(size(B,1),88)];
            sigma = 0.5;
            Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G'  + specCont * 2* sigma)   ./ ((Xhat .^ (basicParameter.beta-1)) * G' + 4*sigma*B.* [zeros(size(B,1), 89) ones(size(B,1),88)])); 
            Bnew = betaNormC(Bnew,basicParameter.beta);
            Bnew(find(isnan(Bnew)))=0;
            B= Bnew;

            
            Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

        end
        
        Bwang = B;
        Gwang = G;
        
        
        basicAlt = basicParameter; % make alternative basicParameter
        basicAlt.fExt = ceil(basicParameter.fExtSecond / basicParameter.nfft * basicParameter.sr); % forward Extension
        basicAlt.bExt = ceil(basicParameter.bExtSecond / basicParameter.nfft * basicParameter.sr); % backward Extnsion
%         basicAlt.attackLengthFrame = basicParameter.attackLengthFrame + basicAlt.fExt;
        basicAlt.attackLengthSecond = basicParameter.attackLengthSecond + basicAlt.fExtSecond;

        B= Bsheet;
        G =  midi2MatrixOption(midiRef, size(X,2), basicAlt, false, false); % make matrix G with extended note length

        Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
        for i = 1:50

            Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
            Gnew(find(isnan(Gnew)))=0;
            G=Gnew;
            specCont = ([B(2:end,:) ; zeros(1, 177)] + [zeros(1, 177); B(1:end-1,:)] ).* [zeros(size(B,1), 89), ones(size(B,1),88)];
            sigma = 0.5;
            Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G'  + specCont * 2* sigma)   ./ ((Xhat .^ (basicParameter.beta-1)) * G' + 4*sigma*B.* [zeros(size(B,1), 89) ones(size(B,1),88)])); 
            Bnew = betaNormC(Bnew,basicParameter.beta);
            Bnew(find(isnan(Bnew)))=0;
            B= Bnew;
            Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

        end

        Bhyb4 = B;
        Ghyb4 = G;

        if isfield(basicParameter, 'targetMedian')
            targetGain = (basicParameter.targetMedian-basicParameter.dynMed(2))/basicParameter.dynMed(1);
            G = G .* 10 ^( (targetGain - histogramData.f.b1)/20 );
            tempG = (20*log10(G) - targetGain) *  ( (basicParameter.targetRange -basicParameter.dynRan(2))/basicParameter.dynRan(1)/histogramData.f.c1  ) + targetGain;
            G = 10.^(tempG/20);
        
        end
        
        midiVel(:,7) = midiVel(:,6) + midiVel(:,7);
        for i = 1:length(midiVel)
            basisIndex = midiVel(i,4) - basicAlt.minNote + 2;

            [gainCalculated, maxIndex, onset, offset] = findMaxGainByNote(midiVel(i,:), G, basicAlt, B);
            midiVel(i,6) = onset * basicAlt.nfft / basicAlt.sr;
            midiVel(i,7) = offset * basicAlt.nfft / basicAlt.sr;
            
            
            coefA = fittingArray(1, basisIndex-1);
            coefB = fittingArray(2, basisIndex-1);

            logGainFromVel = exp(midiVel(i,5) * coefA + coefB);


            midiVel(i,5) = round(  ( log(gainCalculated) - coefB ) / coefA);    
            gainFromVelVec(i) = logGainFromVel ^0.6;
            gainCalculatedVec(i) = gainCalculated ^0.6;
            if midiVel(i,5) < 0
                midiVel(i,5) = 1;
            end
            if midiVel(i,5) > 127
                midiVel(i,5) = 127;
            end


        end

        midiVel(:,7) = midiVel(:,7) - midiVel(:,6);


    end       

    G = Gsheet;
    B = Bsheet;

end




end


function Bextra = extrapolate(B)
%extrapolate spectral basis matrix
Bextra = B;

for i = 1:size(B,2)
    if sum(B(:,i)) == 0 % if a column is zero vector, 
        for j = 1:size(B,2) %find nearest non-zero column
            if i-j>1 && sum(B(:,i-j)) ~= 0
                j = -j;
                break
            elseif i+j<90 && sum(B(:,i+j)) ~=0
                break
            end
        end
        
        Bextra(:,i) = makeTransitionMatrix(i, i+j, size(B,1)) * B(:,i+j);
        
        
    end
    
    
end

end

function transitionMatrix = makeTransitionMatrix(pitchA, pitchB, binNum)
    transitionMatrix = zeros(binNum);
    pitchRatio = 2^ ( (pitchA - pitchB) /12);
    for i = 1:binNum
        centerFrequency = 22050/binNum * (i -0.5);
        mappedFrequencyBin = (centerFrequency / pitchRatio) / (22050/binNum) +0.5;
        if floor(mappedFrequencyBin) == 0
            mappedFrequencyBin = 1;
        end
        
        if ceil(mappedFrequencyBin) > binNum
            break
        end
        
        transitionMatrix(i,floor(mappedFrequencyBin)) = 1 - ( mappedFrequencyBin - floor(mappedFrequencyBin) ) ;
        transitionMatrix(i,ceil(mappedFrequencyBin)) = mappedFrequencyBin - floor(mappedFrequencyBin);
        
    end
end

