function [G, B] = basisNMFoption(X, G, basicParameter, iteration, Gfixed, attackMatrix, initialB, dataSource)

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
    if basicParameter.harmConstrain && basicParameter.softConstraint == false
        B = initializeWwithHarmonicConstraint(basicParameter);
    end
elseif strcmp(dataSource, 'data')

    if basicParameter.useInitialB && exist('initialB')
        B = initialB;
    else
        B = rand(size(X,1), size(G,1));
        if basicParameter.harmConstrain && basicParameter.softConstraint == false
           B = initializeWwithHarmonicConstraint(basicParameter); 
        end
    end
end

% if basicParameter.BpartialUpdate
%     harmBoolean = initializeWwithHarmonicConstraint(basicParameter); 
%     harmBoolean(harmBoolean>0) = 1;
% end
 
if basicParameter.rankMode > 3
    [G, B] = NMFwithMatrix(G, B, X, basicParameter, iteration);

else

    Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) + eps;


    if basicParameter.GpreUpdate && size(initialB,1)~=1 && ~basicParameter.Gfixed
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
            if basicParameter.rankMode == 2 && basicParameter.GpartialUpdate;
                Gnew = updateAttackOnly(G, X, B, Xhat, basicParameter.beta);
            end

        else
            Bnew = betaNormC(Bnew,beta);
            Gnew = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, attackMatrix);

        end
        
        Bnew = betaNormC(Bnew,basicParameter.beta);
        Bnew(find(isnan(Bnew)))=0;
        Gnew(find(isnan(Gnew)))=0;

        B = Bnew;
        G = Gnew;

        Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode) + eps;

%         betaDivVector(length(betaDivVector)+1) = betaDivergenceMatrix(X, Xhat, beta);
    end  
end


end