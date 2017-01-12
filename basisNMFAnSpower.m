function [G B] = basisNMFAnS(Y, sheetMatrix, beta)

G = sheetMatrix(max(find(sum(sheetMatrix,2)==0))+1: size(sheetMatrix,1), :);
B = rand(size(Y,1), size(G,1));

Yhat = sqrt(B.^2 * G.^2);
betaDivergence = betaDivergenceMatrix(Y, Yhat, beta)

%[B, G, cost] = beta_nmf_H(Y, beta, 10, B, G);


B = B .* ((Y .* (Yhat .^(beta-2) ) * G') ./ ((Yhat .^ (beta-1)) * G'));
G = G .* ( B' * (Y .* (Yhat .^(beta-2) )) ./ (B' * (Yhat .^ (beta-1))));

B = betaNormC(B,beta);
%B = normc(B);
Yhat = sqrt(B.^2 * G.^2);
betaDivergence = betaDivergenceMatrix(Y, Yhat, beta)



for i = 1:50
    B = B .* ((Y .* (Yhat .^(beta-2) ) * G') ./ ((Yhat .^ (beta-1)) * G'));
    G = G .* ( B' * (Y .* (Yhat .^(beta-2) )) ./ (B' * (Yhat .^ (beta-1))));

    B = betaNormC(B,beta); 
    %B = normc(B);

    Yhat = sqrt(B.^2 * G.^2);
    betaDivergence = betaDivergenceMatrix(Y, Yhat, beta)
end  