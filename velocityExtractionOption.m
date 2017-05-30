function [G, midiVel, error, errorPerNoteResult, refVelCompare, maxIndexVector, histogramData] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter)

if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
    [X, basicParameter.sr] = audio2spectrogram(audioFilename, basicParameter);
    if strcmp(basicParameter.scale, 'midi')
    X = basicParameter.map_mx * X;
    end
elseif strcmp(basicParameter.scale, 'erbt')
    [X, f, alen] = audio2erbt(audioFilename, basicParameter);
end
fittingArray = basicParameter.fittingArray;

% Rewrite MIDI with fixed times
midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);
basicParameter.MIDI = midiRef;

sheetMatrixMidi = midi2MatrixOption(midiRef, size(X,2), basicParameter, false, basicParameter.weightOnAttack);


% Calculate Gx
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

elseif strcmp(basicParameter.scale, 'erbt')
    [G B] = erbtHarmclusNMF(X, G, B , 250,f,alen, basicParameter, false); 
    
    G = vertcat(G(end,:),G);
    G(end,:) = [];
end

if basicParameter.fittingArray(1,1)

    % evaluate the result
    midiVel = readmidi_java(MIDIFilename,true);
    midiVel(:,7) = midiVel(:,6) + midiVel(:,7);
    maxIndexVector = zeros(size(midiVel,1),1);
    gainFromVelVec = zeros(size(midiVel,1),1);
    gainCalculatedVec = zeros(size(midiVel,1),1);

    
    histogramData = [];
%     [histogramData.histData, histogramData.histMIDI, histogramData.f, histogramData.f2]= makeHistogram(MIDIFilename, G, basicParameter);
    [~, ~, histogramData.f, histogramData.f2]= makeHistogram(MIDIFilename, G, basicParameter);

    if isfield(basicParameter, 'targetMedian')
        targetGain = (basicParameter.targetMedian-basicParameter.dynMed(2))/basicParameter.dynMed(1);
        G = G .* 10 ^( (targetGain - histogramData.f.b1)/20 );
        tempG = (20*log10(G) - targetGain) *  ( (basicParameter.targetRange -basicParameter.dynRan(2))/basicParameter.dynRan(1)/histogramData.f.c1  ) + targetGain;
        G = 10.^(tempG/20);
        
    end
    

    for i = 1:length(midiVel)
        
        basisIndex = midiVel(i,4) - basicParameter.minNote + 2;

        [gainCalculated, maxIndex] = findMaxGainByNote(midiVel(i,:), G, basicParameter);
        
        
        maxIndexVector(i) = maxIndex;

        coefA = fittingArray(1, basisIndex-1);
        coefB = fittingArray(2, basisIndex-1);

        logGainFromVel = exp(midiVel(i,5) * coefA + coefB);
        

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


    end
    % calculate error
    [error, errorPerNoteResult, refVelCompare] = calculateError(midiRef, midiVel, gainFromVelVec, gainCalculatedVec);


    %plot(betaDivVector)
end

if isfield(basicParameter, 'transcription')
    Gsheet= G;
    Bsheet= B;        
    temporalConstraintDummy = zeros(size(G));

    if basicParameter.transcription
        G = rand(size(Gsheet));
        
        Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

        

        for i = 1:50
            
            Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, temporalConstraintDummy);
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
       


%         for i = 1:length(midiVel)
%             basisIndex = midiVel(i,4) - basicParameter.minNote + 2;
% 
%             [gainCalculated, maxIndex, onset, offset] = findMaxGainByNote(midiVel(i,:), G, basicParameter);
%             midiVel(i,6) = onset * basicParameter.nfft / basicParameter.sr;
%             midiVl(i,7) = offset * basicParameter.nfft / basicParameter.sr;
% 
%         end

        Grand = G;
        Brand = B;
        B = Bsheet;
    
        
        basicAlt = basicParameter;
        basicAlt.fExt = 100;
        basicAlt.bExt = 100;
        basicAlt.attackLengthFrame = basicParameter.attackLengthFrame - basicAlt.onsetFine;

        G =  midi2MatrixOption(midiRef, size(X,2), basicAlt, false, false);
        
        Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

 
        for i = 1:50
            Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, temporalConstraintDummy);
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
        Ghyb = G;
        Bhyb = B;
        
        
        
        
        B = Bsheet;       
        G =  rand(size(Gsheet));
        
        Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

 
        for i = 1:50
            Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, temporalConstraintDummy);
            Gnew(find(isnan(Gnew)))=0;
            G=Gnew;
            
            Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

        end
             
        Ghyb2 = G;
        Bhyb2 = B;
        
        
        B = initializeWwithHarmonicConstraint(basicParameter);
        G =  midi2MatrixOption(midiRef, size(X,2), basicParameter, false, false);
        Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

 
        for i = 1:50
            Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, temporalConstraintDummy);
            Gnew(find(isnan(Gnew)))=0;
            G=Gnew;
            Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
            Bnew = betaNormC(Bnew,basicParameter.beta);
            Bnew(find(isnan(Bnew)))=0;
            B= Bnew;
            
            Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;

        end
             
        Ghyb3 = G;
        Bhyb3 = B;
        
        
        
        B = initializeWwithHarmonicConstraint(basicParameter);
        G = rand(size(Gsheet));
        
        Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
        for i = 1:50
            
            Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, temporalConstraintDummy);
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
        
        

    end       

    G = Gsheet;
    B = Bsheet;

end


midiVel(:,7) = midiVel(:,7) - midiVel(:,6);


end