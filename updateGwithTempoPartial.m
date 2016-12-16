function updatedG = updateGwithTempoPartial(G, X, Bcopy, Xhat, beta, alpha)
    
    tempG1 = G(1:89,:);
    tempG2 = G(90:end,:);

    tempB1 = Bcopy(:,1:89);
    tempB2 = Bcopy(:,90:end);
    
    updatedG1 = tempG1 .* ( (tempB1' * (X .* (Xhat .^(beta-2) )) )  ./ (tempB1' * (Xhat .^ (beta-1))) );
    updatedG2 = updateGwithTempo(tempG2,X,tempB2,Xhat,beta,alpha);

    updatedG(1:89,:) = updatedG1;
    updatedG(90:177,:) = updatedG2;
   
end