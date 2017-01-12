function [G B] = basisNMFoption(X, sheetMatrix, basicParameter, iteration, Gfixed, attackMatrix)

if nargin < 6
    attackMatrix = false;
end

beta = basicParameter.beta;
betaDivVector =[];

G = sheetMatrix(basicParameter.minNote-1:end,:);
B = rand(size(X,1), size(G,1));

Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode);
% if strcmp(basicParameter.spectrumMode, 'linear')
%     Yhat = B * G;
% elseif strcmp(basicParameter.spectrumMode, 'power')
%     Yhat = sqrt(B.^2 * G.^2);
% end
betaDivVector(length(betaDivVector)+1) = betaDivergenceMatrix(X, Xhat, beta);

%[B, G, cost] = beta_nmf_H(Y, beta, 10, B, G);



for i = 1:iteration
    B = B .* ((X .* (Xhat .^(beta-2) ) * G') ./ ((Xhat .^ (beta-1)) * G'));
    B = betaNormC(B,beta); 
    
    if Gfixed
        if basicParameter.rankMode == 2
            
        end
    else
        G = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, attackMatrix);
        G(find(isnan(G)))=0;
    end

    B(find(isnan(B)))=0;
    G(find(isnan(G)))=0;

    %B = normc(B);
    Xhat = (B.^basicParameter.spectrumMode * G.^basicParameter.spectrumMode) .^ (1/basicParameter.spectrumMode);

%     if strcmp(basicParameter.spectrumMode, 'linear')
%         Yhat = B * G;
%     elseif strcmp(basicParameter.spectrumMode, 'power')
%         Yhat = sqrt(B.^2 * G.^2);
%     end
    %betaDivVector(length(betaDivVector)+1) = betaDivergenceMatrix(Y, Yhat, beta);
end  

figure();
plot(betaDivVector);

end