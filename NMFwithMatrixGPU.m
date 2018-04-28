function [G, B] = NMFwithMatrixGPU(G, B, X, basicParameter, iteration, constraintMatrix, attackMatrix)

if nargin<6
    constraintMatrix = zeros(size(G));
end

if nargin<7
%     T = zeros(size(B,2));
    attackMatrix = zeros(size(G));
end

% Ggpu = gpuArray(G);
% Bgpu = gpuArray(B);
% X = gpuArray(X);

[boolMatL, boolMatR] = makeActivationDiffBool(G, basicParameter);

if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')

    Xhat = (B.^basicParameter.spectrumMode * G .^ basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
    
    
    if basicParameter.GpreUpdate && mean(mean(B)) <0.3
       for i = 1:basicParameter.GpreUpdate
           Gnew =updateG(G, B, X, Xhat, basicParameter, constraintMatrix, attackMatrix);
           G = Gnew;
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

    prevDiv = Inf;
    for i = 1:iteration
        Bnew = B;
%         Gnew = G;
        if i < basicParameter.updateBnumber || iteration == basicParameter.iterationData
            if basicParameter.BpartialUpdate
                tempUpdate = (X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G') .* harmBoolean;
                tempUpdate(tempUpdate==0) = 1;
                Bnew = B .* tempUpdate;
                Bnew = betaNormC(Bnew,basicParameter.beta);
                Bnew(find(isnan(Bnew)))=0;
            else
%                 Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
                if basicParameter.rankMode >= 2;
%                     specCont = ([B(2:end,:) ; zeros(1, 177)] + [zeros(1, 177); B(1:end-1,:)] ).* [zeros(size(B,1), 89), ones(size(B,1),88)];
%                     sigma = basicParameter.beta1;
%                     Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G'  + specCont * 2* sigma)   ./ ((Xhat .^ (basicParameter.beta-1)) * G' + 4*sigma*B.* [zeros(size(B,1), 89) ones(size(B,1),88)])); 
%                     Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
                    Bnew = updateB(B, G, X, Xhat, basicParameter);
                else
                    Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G') ./ ((Xhat .^ (basicParameter.beta-1)) * G'));
                end

                if basicParameter.beta3 == 0
                    Bnew = betaNormC(Bnew,basicParameter.beta);
                end
                Bnew(find(isnan(Bnew)))=0;
            end
        end
        tic
        G =updateG(G, B, X, Xhat, basicParameter, constraintMatrix, attackMatrix, boolMatL, boolMatR);
        toc
%         Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter);
%         Gnew(find(isnan(Gnew)))=0;
        


        B=Bnew;
%         G=Gnew;

        Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) +eps;
        
%         if mod(i,5) == 1
            betaDiv = betaDivergenceMatrix(X, Xhat, basicParameter.beta);
            progress= betaDiv/prevDiv
            if 1 - betaDiv/prevDiv < 1e-3
                break
            end
            i
            prevDiv = betaDiv;
%         end
        
        
        
    end
%     D = sum(betaDivergence(X, Xhat, basicParameter.beta))


elseif strcmp(basicParameter.scale, 'erbt')
    [G B] = erbtHarmclusNMF(X, G, B , 250,f,alen, basicParameter, false); 
    
    G = vertcat(G(end,:),G);
    G(end,:) = [];
end


% temporal modeling
% if nargout == 3
%     for i = 1:basicParameter.maxNote - basicParameter.minNote +1
%         basisStart = (i-1) * basicParameter.rankMode + 2;
%         basisEnd = basisStart + basicParameter.rankMode -1;
%         T(basisStart:basisEnd,basisStart:basisEnd) = G(basisStart:basisEnd,1:end-1)*G(basisStart:basisEnd,2:end)';
%     end
%     T = bsxfun( @rdivide, T, sum(T, 2)+eps);
% end

end

function [G] = updateG(G, B, X, Xhat, basicParameter, softConstraintMatrix, attackMatrix, boolMatL, boolMatR)
    if nargin<7
        attackMatrix = zeros(size(G));
    end

    alpha1= basicParameter.alpha1;
    alpha2= basicParameter.alpha2;
    alpha3= basicParameter.alpha3;
    alpha4= basicParameter.alpha4;
    
    
    if isfield(basicParameter, 'softConstraint') && basicParameter.softConstraint
%         [diffMatrixL, diffMatrixR] = multiRankActivationConstraintMatrix (G, basicParameter);
        G =  G .* ( B' * (X .* (Xhat .^(basicParameter.beta-2) )) + alpha1 * softConstraintMatrix  + 2* alpha2 * ([0 zeros(1, size(G,2)-1); zeros(size(G,1)-1,1) G(1:end-1,1:end-1) ] .* boolMatL + [G(2:end,2:end) zeros(size(G,1)-1,1); zeros(1, size(G,2)-1) 0].* boolMatR ) ) ./ (B' * (Xhat .^ (basicParameter.beta-1)) + (alpha1 + alpha3) * ones(size(G)) + 4*alpha2*G );
%         if T(2,2) ~= 0
%             th1 =  Gnew .* (alpha4+ T'*[zeros(441,1), Gnew(:,1:end-1)]);
%             th1(:,1) = 0;
%             th2 =  Gnew .* (alpha4+ T*[ Gnew(:,2:end), zeros(441,1)]);
%             th2(:,end) = 0;
% %             th1(:,1) = Gnew(:,1);
% %             th2(:,size(Gnew,2)) = Gnew(:,end);
% %             for i = 1:size(Gnew,2)-1
% %                 th1(:,i+1) = Gnew(:,i+1) .* (alpha4 + T'*Gnew(:,i));
% %                 th2(:,end-i) = Gnew(:,end-i) .* (alpha4 + T*Gnew(:,end-i+1));
% %             end
%             Gnew = (th1 + th2)/2;
%         end
    else
        G = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, attackMatrix);
    end
    G(find(isnan(G)))=0;

end

function Bnew = updateB(B, G, X, Xhat, basicParameter)
    beta1 = basicParameter.beta1;
    beta2 = basicParameter.beta2;
    beta3 = basicParameter.beta3;
    gam = basicParameter.gamma;
    
    attackBasisBoolean = zeros(size(B));
    softConstraintMatrix = zeros(size(B));
    specContU = zeros(size(B));
    specContD = zeros(size(B));
    
    
    if basicParameter.rankMode > 2 && basicParameter.softConstraint

        for i = 1:basicParameter.maxNote - basicParameter.minNote +1 %for each key
            attackBasisBoolean(:, 2+(i-1)*basicParameter.rankMode) = 1;
        end
        specContU = [zeros(1, size(B,2)); B(1:end-1, :)];
        specContD = [B(2:end, :); zeros(1, size(B,2))];
        
        softConstraintMatrix = initializeWwithHarmonicConstraint(basicParameter);
        softConstraintMatrix(softConstraintMatrix>0) = 1;
    
    
        susBasisBoolean = ~attackBasisBoolean;
        susBasisBoolean(:,1) = 0;
        [gammaM, gammaP ] = gammaMatrix(B, gam, susBasisBoolean, basicParameter);        
        
        
        attM = (specContU + specContD) .*attackBasisBoolean;
        attP = B.* attackBasisBoolean;
        
        XXhat = gpuArray(X .* (Xhat .^(basicParameter.beta-2)));
        Ggpu = gpuArray(G);
        
        Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G'  + 2* beta1 * attM + beta2 * softConstraintMatrix + beta3 * gam^2 * gammaM )   ./ ((Xhat .^ (basicParameter.beta-1)) * G' + 4*beta1*attP + beta2 * ones(size(B)) + beta3 * gam^2 * gammaP  ) ); 
    else
        Bnew = B .* ((X .* (Xhat .^(basicParameter.beta-2) ) * G' )   ./ ((Xhat .^ (basicParameter.beta-1)) * G') );
    end
end

    
function [diffMatrixL, diffMatrixR] = multiRankActivationConstraintMatrix (G, basicParameter)
    diffMatrixL = [0 zeros(1, size(G,2)-1); zeros(size(G,1)-1,1) G(1:end-1,1:end-1) ];
    diffMatrixR = [G(2:end,2:end) zeros(size(G,1)-1,1); zeros(1, size(G,2)-1) 0];
        
    diffMatrixL( 1, :) = 0;
    diffMatrixR( 1, :) = 0;
    for i = 1: (basicParameter.maxNote - basicParameter.minNote +1) 
        diffMatrixL( (i-1) * basicParameter.rankMode + 2, :) = 0;
%         diffMatrixR( (i-1) * basicParameter.rankMode + 2, :) = 0;
        diffMatrixR( i * basicParameter.rankMode + 1, :) = 0;   
    end

end 

function  [gammaMatMinus, gammaMatPlus ] = gammaMatrix(B, gam, susBasisBoolean, basicParameter)
    
%     B = B .* susBasisBoolean;
    shiftL = [B(:,2:end) zeros(size(B,1),1)];
    shiftR = [zeros(size(B,1),1) B(:,1:end-1)];
    
    for i = 1: (basicParameter.maxNote - basicParameter.minNote +1) 
        shiftL(:, i * basicParameter.rankMode + 1, : ) = 0;
        shiftR(:, (i-1) * basicParameter.rankMode + 2) = 0;   
    end
    
    diffMatrixL =  B - shiftR;
    diffMatrixR = shiftL - B;
    

    
    
    gammaMatMinus = shiftR .* exp(diffMatrixL*gam -1) + shiftL .* exp(diffMatrixR * gam -1);
    gammaMatPlus = B.* exp(diffMatrixL * gam -1) + B.* exp(diffMatrixR*gam-1);
    
    gammaMatMinus = gammaMatMinus .* susBasisBoolean;
    gammaMatPlus = gammaMatPlus .* susBasisBoolean;


end

function [boolMatL, boolMatR] = makeActivationDiffBool(G, basicParameter)
    
    boolMatL = boolean(zeros(size(G)));
    boolMatR = boolMatL;

    boolMatL(1,:) = 0;
    boolMatR(1,:) = 0;
    for i = 1: (basicParameter.maxNote - basicParameter.minNote +1) 
        boolMatL( (i-1) * basicParameter.rankMode + 2, :) = 0;
%         diffMatrixR( (i-1) * basicParameter.rankMode + 2, :) = 0;
        boolMatR( i * basicParameter.rankMode + 1, :) = 0;   
    end
end