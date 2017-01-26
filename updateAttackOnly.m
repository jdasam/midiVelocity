function G = updateAttackOnly(G, X, B, Xhat, beta)

    tempG2 = G(90:end,:);
    tempB2 = B(:,90:end);

    updatedG2 = tempG2 .* ( (tempB2' * (X .* (Xhat .^(beta-2) )) )  ./ (tempB2' * (Xhat .^ (beta-1))) );

    G(90:177,:) = updatedG2;
    
end