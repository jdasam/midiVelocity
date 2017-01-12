function updatedG = updateGwithTempoPartial(G, X, B, Xhat, basicParameter)
    
    beta = basicParameter.beta;
    alpha = basicParameter.alpha;
    
    if basicParameter.rankMode ==1
        tempAttackMatrix = midi2MatrixOption(basicParameter.MIDI, size(X,2), basicParameter, true, false);
        updatedG = updateGwithTempoExceptAttack(G,X,B,Xhat,beta,alpha,tempAttackMatrix(20:108,:));
        %updatedG = updateGwithForcedSustain(G,X,B,Xhat,beta,alpha,tempAttackMatrix(20:108,:));
        
        
    elseif basicParameter.rankMode == 2
    
        tempG1 = G(1:89,:);
        tempG2 = G(90:end,:);

        tempB1 = B(:,1:89);
        tempB2 = B(:,90:end);

        updatedG1 = tempG1 .* ( (tempB1' * (X .* (Xhat .^(beta-2) )) )  ./ (tempB1' * (Xhat .^ (beta-1))) );
        updatedG2 = updateGwithForcedSustain(tempG2,X,tempB2,Xhat,beta,alpha,tempG1(2:89,:));

        updatedG(1:89,:) = updatedG1;
        updatedG(90:177,:) = updatedG2;
    end
   
end