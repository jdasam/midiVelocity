function updatedG = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, tempAttackMatrix)
    if nargin < 6
        tempAttackMatrix = false;
    end

    beta = basicParameter.beta;
    alpha = basicParameter.alpha;
    
    if basicParameter.rankMode ==1
        if ~tempAttackMatrix
            tempAttackMatrix = midi2MatrixOption(basicParameter.MIDI, size(X,2), basicParameter, true, false);
        end
        updatedG = updateGwithTempoExceptAttack(G,X,B,Xhat,beta,alpha,tempAttackMatrix);
     
    elseif basicParameter.rankMode == 2
    
        tempG1 = G(1:89,:);
        tempG2 = G(90:end,:);

        tempB1 = B(:,1:89);
        tempB2 = B(:,90:end);
    
        if ~tempAttackMatrix
            %tempAttackMatrix = vertcat(zeros(1,size(tempG2,2)), tempG2);
            tempAttackMatrix =  midi2MatrixOption(basicParameter.MIDI, size(X,2), basicParameter, true, false);
        end
        updatedG1 = updateGwithTempoExceptAttack(tempG1, X, tempB1,Xhat, beta, alpha, tempAttackMatrix);                
        updatedG2 = tempG2 .* ( (tempB2' * (X .* (Xhat .^(beta-2) )) )  ./ (tempB2' * (Xhat .^ (beta-1))) );
      
        updatedG(1:89,:) = updatedG1;
        updatedG(90:177,:) = updatedG2;
    
    elseif basicParameter.rankMode >= 3
        updatedG =  G .* ( B' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (B' * (Xhat .^ (basicParameter.beta-1))  ));
    end
   
end