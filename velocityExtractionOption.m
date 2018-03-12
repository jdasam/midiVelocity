function [G, midiVel, error, errorPerNoteResult, refVelCompare, maxIndexVector, histogramData, B, numberOfNotesByError, gainRefVelCompare] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter)

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

if basicParameter.postUpdate
    tempBasicParam = basicParameter;
    tempBasicParam.alpha1 = 0;
    tempBasicParam.alpha2 = 0;
    tempBasicParam.alpha3 = 0;
    tempBasicParam.updateBnumber = 0;
    tempBasicParam.iterationPiece = basicParameter.iterationPost;
    
    G = NMFwithMatrix(G, B, X, tempBasicParam, tempBasicParam.iterationPiece, softConstraintMatrix);
end



if basicParameter.fittingArray(1,1)

    % evaluate the result
%     midiVel = readmidi_java(MIDIFilename,true);
%     midiVel(:,7) = midiVel(:,6) + midiVel(:,7);
    maxIndexVector = zeros(size(midiVel,1),1);
    gainFromVelVec = zeros(size(midiVel,1),1);
    gainCalculatedVec = zeros(size(midiVel,1),1);
    gainRefVelCompare = zeros(size(midiVel,1),2);
    
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
        
        if basicParameter.saveOnsetCluster
            [gainCalculated, maxIndex, ~, ~, onsetCluster] = findMaxGainByNote(midiVel(i,:), G, basicParameter, B);
        else
            [gainCalculated, maxIndex] = findMaxGainByNote(midiVel(i,:), G, basicParameter, B);
            onsetCluster = [];
        end
      
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
    if basicParameter.saveOnsetCluster
        save('onsetCluster.mat', 'onsetClusterArray', 'onsetMatchedVel')
    end
    midiVel(:,7) = midiVel(:,7) - midiVel(:,6);
    gainRefVelCompare(:,1) = gainFromVelVec;
    gainRefVelCompare(:,2) = gainCalculatedVec;

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
        
        [extraNotesPerKey, omittedNotesPerKey, thresholdForKey, fscoreList] = getExtraNotesAndThresholdForKey(G, midiRef, basicParameter);
        midiTrans = makeMidiWithExtraNotes(midiRef, extraNotesPerKey, omittedNotesPerKey);
        midiTrans(:,7) = midiTrans(:,7) - midiTrans(:,6);
        writemidi_seconds(midiTrans, 'test.mid');
        fileName = strsplit(audioFilename, '.mp3');
        txtFileName = strcat(fileName{1},'_corresp.txt');
        if exist(txtFileName, 'file')
            [~, ~, ~, ~, ~, ~, missedNotesList, addedNotesList, alignedNotesNum] = calMidiSyncErrorAndDiff(txtFileName);
            [correctNotesError, addedNotesError, missedNotesError]= calFscoreByCategory(extraNotesPerKey, omittedNotesPerKey, addedNotesList, missedNotesList, alignedNotesNum)
        end
        
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
%             sigma = 0.5
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
%         B = initializeWwithHarmonicConstraint(basicParameter);
%         G = rand(size(Gsheet));
%         
%         Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
%         for i = 1:50
%             
%             Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
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
%         Brand2 = B;
%         Grand2 = G;
% 
%         
%         B = extrapolate(Bsheet);
%         G = rand(size(Gsheet));
%         
%         Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
%         for i = 1:50
%             
%             Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
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
%         Bwang = B;
%         Gwang = G;
%         
%         
%         basicAlt = basicParameter; % make alternative basicParameter
%         basicAlt.fExt = ceil(basicParameter.fExtSecond / basicParameter.nfft * basicParameter.sr); % forward Extension
%         basicAlt.bExt = ceil(basicParameter.bExtSecond / basicParameter.nfft * basicParameter.sr); % backward Extnsion
% %         basicAlt.attackLengthFrame = basicParameter.attackLengthFrame + basicAlt.fExt;
%         basicAlt.attackLengthSecond = basicParameter.attackLengthSecond + basicAlt.fExtSecond;
% 
%         B= Bsheet;
%         G =  midi2MatrixOption(midiRef, size(X,2), basicAlt, false, false); % make matrix G with extended note length
% 
%         Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
%         for i = 1:50
% 
%             Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
%             Gnew(find(isnan(Gnew)))=0;
%             G=Gnew;
%             specCont = ([B(2:end,:) ; zeros(1, 177)] + [zeros(1, 177); B(1:end-1,:)] ).* [zeros(size(B,1), 89), ones(size(B,1),88)];
%             sigma = 0.5;
%             Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G'  + specCont * 2* sigma)   ./ ((Xhat .^ (basicParameter.beta-1)) * G' + 4*sigma*B.* [zeros(size(B,1), 89) ones(size(B,1),88)])); 
%             Bnew = betaNormC(Bnew,basicParameter.beta);
%             Bnew(find(isnan(Bnew)))=0;
%             B= Bnew;
%             Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
% 
%         end
% 
%         Bhyb4 = B;
%         Ghyb4 = G;
% 
%         if isfield(basicParameter, 'targetMedian')
%             targetGain = (basicParameter.targetMedian-basicParameter.dynMed(2))/basicParameter.dynMed(1);
%             G = G .* 10 ^( (targetGain - histogramData.f.b1)/20 );
%             tempG = (20*log10(G) - targetGain) *  ( (basicParameter.targetRange -basicParameter.dynRan(2))/basicParameter.dynRan(1)/histogramData.f.c1  ) + targetGain;
%             G = 10.^(tempG/20);
%         
%         end
%         
%         midiVel(:,7) = midiVel(:,6) + midiVel(:,7);
%         for i = 1:length(midiVel)
%             basisIndex = midiVel(i,4) - basicAlt.minNote + 2;
% 
%             [gainCalculated, maxIndex, onset, offset] = findMaxGainByNote(midiVel(i,:), G, basicAlt, B);
%             midiVel(i,6) = onset * basicAlt.nfft / basicAlt.sr;
%             midiVel(i,7) = offset * basicAlt.nfft / basicAlt.sr;
%             
%             
%             coefA = fittingArray(1, basisIndex-1);
%             coefB = fittingArray(2, basisIndex-1);
% 
%             logGainFromVel = exp(midiVel(i,5) * coefA + coefB);
% 
% 
%             midiVel(i,5) = round(  ( log(gainCalculated) - coefB ) / coefA);    
%             gainFromVelVec(i) = logGainFromVel ^0.6;
%             gainCalculatedVec(i) = gainCalculated ^0.6;
%             if midiVel(i,5) < 0
%                 midiVel(i,5) = 1;
%             end
%             if midiVel(i,5) > 127
%                 midiVel(i,5) = 127;
%             end
% 
% 
%         end
% 
%         midiVel(:,7) = midiVel(:,7) - midiVel(:,6);
% 
% 
    end       
% 
%     G = Gsheet;
%     B = Bsheet;

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

function [extraNotesPerKey,omittedNotesPerKey, thresholdForKey, fscoreList] = getExtraNotesAndThresholdForKey(G, midiRef, basicParameter)
Gflux = getGainFlux(G, basicParameter);

thresholdForKey = zeros(88,1);
fscoreList =  zeros(88,1);
extraNotesPerKey = zeros(1,88);
omittedNotesPerKey = zeros(1,88);
for i = 1:size(Gflux,1)
    nmatList = midiRef(midiRef(:,4) == i + basicParameter.minNote -1,6 );
    nmatListL = midiRef(midiRef(:,4) == i + basicParameter.minNote -2,6 );
    nmatListU = midiRef(midiRef(:,4) == i + basicParameter.minNote,6 );
    if nmatList 
        keyThreshold = 0;
        maximumF = 0;
        optimalExtraNotes = 0;
        optimalOmittedNotes = 0;
        for j = 1:40
            gainRow = Gflux(i,:);
            gainRowL = Gflux(i-1,:);
            gainRowU = Gflux(i+1,:);
            threshold = j * 0.0025;
            noteIndexList = findNoteFromGainRow(gainRow, threshold);
            noteIndexListL = findNoteFromGainRow(gainRowL, threshold);
            noteIndexListU = findNoteFromGainRow(gainRowU, threshold);
            
            if isempty(noteIndexList) && isempty(noteIndexListL) && isempty(noteIndexListU)
                break
            end
            noteList = noteIndexList * basicParameter.nfft / basicParameter.sr;
            noteListL = noteIndexListL * basicParameter.nfft / basicParameter.sr;
            noteListU = noteIndexListU * basicParameter.nfft / basicParameter.sr;
            
            [extraNotes, omittedNotes, precision, recall] = compareNotes(nmatList, noteList);
            [extraNotesL, omittedNotesL, precisionL, recallL] = compareNotes(nmatListL, noteListL);
            [extraNotesU, omittedNotesU, precisionU, recallU] = compareNotes(nmatListU, noteListU);
            
            alignedNotesNum = size(noteList,2) - size(extraNotes,2);
            alignedNotesNumL = size(noteListL,2) - size(extraNotesL,2);
            alignedNotesNumU = size(noteListU,2) - size(extraNotesU,2);
            
            totalPrecision = (alignedNotesNum + alignedNotesNumL + alignedNotesNumU ) / (size(noteList,2) + size(noteListL,2) + size(noteListU,2));
            totalRecall = (alignedNotesNum + alignedNotesNumL + alignedNotesNumU )  / (size(nmatList,1) + size(nmatListL,1) + size(nmatListU,1));
            
            fscore = 2 * (totalPrecision * totalRecall) / (totalPrecision + totalRecall);
            if fscore > maximumF 
                maximumF = fscore;
                keyThreshold = threshold;
                optimalExtraNotes = extraNotes;
                optimalOmittedNotes = omittedNotes;
            end

        end
        thresholdForKey(i) = keyThreshold;
        fscoreList(i) = maximumF;
        extraNotesPerKey(1:length(optimalExtraNotes), i) = optimalExtraNotes;
        omittedNotesPerKey(1:length(optimalOmittedNotes), i) = optimalOmittedNotes;
    end
end

end

function Gflux = getGainFlux(G, basicParameter)

Gsum = zeros(basicParameter.maxNote - basicParameter.minNote + 1, size(G,2));
for i = 1:size(Gsum,1);
    basisIndexStart = (i-1) * basicParameter.rankMode + 2;
    basisIndexEnd = i * basicParameter.rankMode + 1;
    Gsum(i,:) = sum(G( basisIndexStart:basisIndexEnd,:));
end


% Gflux = Gsum - [zeros(size(Gsum,1), 1) Gsum(:,1:end-1)];
Gflux = 1.5 * Gsum - [zeros(size(Gsum,1), 1) Gsum(:,1:end-1)] - [zeros(size(Gsum,1), 2) Gsum(:,1:end-2)] * 0.5;
Gflux(Gflux<0) = 0;

% Gflux = Gflux / max(max(Gflux));
Gflux = Gflux / max(max(Gflux)) ./ (ones(88,1) * max(Gflux));


end

function noteIndexList = findNoteFromGainRow(gainRow, threshold)
    noteIndexList = find(gainRow>threshold);
    if noteIndexList
        validList = [];
        validList(1) = noteIndexList(1);
        for i = 2:length(noteIndexList)
            if noteIndexList(i) - noteIndexList(i-1) > 3
                validList(length(validList)+1) = noteIndexList(i);
            end
        end
        noteIndexList = validList;
    end
end

function [extraNotes, omittedNotes, precision, recall] = compareNotes(nmatList, noteList)
    numMatchedNote = 0;
    numNoteList = length(noteList);
    numNmatList = length(nmatList);
    matchedStatus = zeros(length(noteList),1);
    for i = 1:numNoteList
        candidates = find( abs(nmatList - noteList(i)) < 0.5);
        if candidates
            nmatList(candidates(1)) =[];
            numMatchedNote = numMatchedNote + 1;
            matchedStatus(i) = 1;
        end
    end
    precision = sum(matchedStatus) / numNoteList;
    recall =  sum(matchedStatus) / numNmatList;
    extraNotes = noteList(matchedStatus==0);
    omittedNotes = nmatList;
end


function midiTrans = makeMidiWithExtraNotes(midiRef, extraNotesPerKey, omittedNotesPerKey)
    midiTrans = midiRef;
    for i=1:size(extraNotesPerKey,2)
        dataSize = max(find(extraNotesPerKey(:,i)>0));
        for j = 1: dataSize
            % midi(:,7) == offset time, not duration
            midiLine = [0 0 1 i+20 60 extraNotesPerKey(j,i) extraNotesPerKey(j,i)+0.5 2];
            midiTrans(length(midiTrans)+1, :) = midiLine;
        end 
    end
    for i=1:size(omittedNotesPerKey,2)
        dataSize = max(find(omittedNotesPerKey(:,i)>0));
        for j = 1: dataSize
            midiTrans(midiTrans(:,6)==omittedNotesPerKey(j,i) & midiTrans(:,5) == i+20 ,:) =[];
        end 
    end
end

function [correctNotesError, addedNotesError, missedNotesError]= calFscoreByCategory(extraNotesPerKey, omittedNotesPerKey, addedNotesList, missedNotesList, alignedNotesNumber)
    
    addedNotesNumber = comparePerKeyAndList(extraNotesPerKey, addedNotesList);
    missedNotesNumber = comparePerKeyAndList(omittedNotesPerKey, missedNotesList);    
    
    addedNotesError = [addedNotesNumber(2)/addedNotesNumber(1), addedNotesNumber(2)/size(addedNotesList,1) ];
    addedNotesError(3) = 2* addedNotesError(1) * addedNotesError(2) /sum(addedNotesError);
    
    missedNotesError = [missedNotesNumber(2)/missedNotesNumber(1), missedNotesNumber(2)/size(missedNotesList,1) ];
    missedNotesError(3) = 2* missedNotesError(1) * missedNotesError(2) /sum(missedNotesError);
    
    correctNotesError = [1, (alignedNotesNumber - (missedNotesNumber(1) - missedNotesNumber(2)))/alignedNotesNumber];
    correctNotesError(3) = 2* correctNotesError(1) * correctNotesError(2) /sum(correctNotesError);
    
    
end


function numberOfEstimation = comparePerKeyAndList(notesPerKey, notesList)
    numberOfEstimation = [0, 0];
    for i=1:88
        dataSize = max(find(notesPerKey(:,i)>0));
        for j=1:dataSize
            numberOfEstimation(1) = numberOfEstimation(1) + 1; %number of estimation in added notes
            candidates = find((abs(notesList(:,1) - notesPerKey(j,i))<0.5));
            for k=1:length(candidates)
                if notesList(candidates(k),2) == i+20
                    numberOfEstimation(2) = numberOfEstimation(2) + 1; %number of correct estimation
                    break;
                end
            end
        end
    end
end