function [G B] = basisNMFoption(Y, sheetMatrix, basicParameter, iteration, Gfixed)

beta = basicParameter.beta;
betaDivVector =[];

G = sheetMatrix(basicParameter.minNote-1:end,:);
B = rand(size(Y,1), size(G,1));

if strcmp(basicParameter.spectrumMode, 'linear')
    Yhat = B * G;
elseif strcmp(basicParameter.spectrumMode, 'power')
    Yhat = sqrt(B.^2 * G.^2);
end
betaDivVector(length(betaDivVector)+1) = betaDivergenceMatrix(Y, Yhat, beta);

%[B, G, cost] = beta_nmf_H(Y, beta, 10, B, G);



for i = 1:iteration
    B = B .* ((Y .* (Yhat .^(beta-2) ) * G') ./ ((Yhat .^ (beta-1)) * G'));
    
    if Gfixed
        if basicParameter.rankMode == 2
            
        end
    else
        G = G .* ( B' * (Y .* (Yhat .^(beta-2) )) ./ (B' * (Yhat .^ (beta-1))));
        B = betaNormC(B,beta); 
    end

    B(find(isnan(B)))=0;
    G(find(isnan(G)))=0;

    %B = normc(B);

    if strcmp(basicParameter.spectrumMode, 'linear')
        Yhat = B * G;
    elseif strcmp(basicParameter.spectrumMode, 'power')
        Yhat = sqrt(B.^2 * G.^2);
    end
    %betaDivVector(length(betaDivVector)+1) = betaDivergenceMatrix(Y, Yhat, beta);
end  

figure();
plot(betaDivVector);

end