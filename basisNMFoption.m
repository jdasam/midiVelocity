function [G B] = basisNMFoption(X, G, basicParameter, iteration, Gfixed, attackMatrix, initialB, dataSource)

alphaSave = basicParameter.alpha;
basicParameter.alpha = 0;

if nargin < 6
    attackMatrix = false;
end

if nargin < 7
    initialB = false;
end

beta = basicParameter.beta;

if strcmp(dataSource, 'scale')
    B = rand(size(X,1), size(G,1));
    if basicParameter.harmConstrain
        B = initializeWwithHarmonicConstraint(basicParameter);
    end
elseif strcmp(dataSource, 'data')

    if basicParameter.useInitialB & initialB
        B = initialB;
    else
        B = rand(size(X,1), size(G,1));
        if basicParameter.harmConstrain 
           B = initializeWwithHarmonicConstraint(basicParameter); 
        end
    end
end

if basicParameter.BpartialUpdate
    harmBoolean = initializeWwithHarmonicConstraint(basicParameter); 
    harmBoolean(harmBoolean>0) = 1;
end
 
Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) + eps;


if basicParameter.GpreUpdate & initialB
    for i = 1:basicParameter.GpreUpdate
        G = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, attackMatrix);
        G(find(isnan(G)))=0;
        Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) + eps;
    end
end



for i = 1:iteration
    Bnew = B;
    Gnew = G;

    if ~basicParameter.BpartialUpdate
        Bnew = B .* ((X .* (Xhat .^(beta-2) ) * G') ./ ((Xhat .^ (beta-1)) * G'));
    else
        tempUpdate = (X .* (Xhat .^(beta-2) ) * G') ./ ((Xhat .^ (beta-1)) * G') .* harmBoolean;
        tempUpdate(tempUpdate==0) = 1;
        Bnew = B .* tempUpdate;
    end
        
    
    if Gfixed
        if basicParameter.rankMode == 2 & basicParameter.GpartialUpdate;
            Gnew = updateAttackOnly(G, X, B, Xhat, basicParameter.beta);
        end
        
    else
        Bnew = betaNormC(Bnew,beta);
        Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, attackMatrix);
        
    end

    Bnew(find(isnan(Bnew)))=0;
    Gnew(find(isnan(Gnew)))=0;
    
    B = Bnew;
    G = Gnew;

    %B = normc(B);
    Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) + eps;

%     if strcmp(basicParameter.spectrumMode, 'linear')
%         Yhat = B * G;
%     elseif strcmp(basicParameter.spectrumMode, 'power')
%         Yhat = sqrt(B.^2 * G.^2);
%     end
    %betaDivVector(length(betaDivVector)+1) = betaDivergenceMatrix(Y, Yhat, beta);
end  

basicParameter.alpha = alphaSave;


end