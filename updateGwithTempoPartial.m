function updatedG = updateGwithTempoPartial(G, X, B, Xhat, basicParameter, tempAttackMatrix)
    if nargin < 6
        tempAttackMatrix = zeros(size(G));
    end

    beta = basicParameter.beta;
    alpha = basicParameter.alpha;
    alpha2= basicParameter.alpha2;
    
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
        [diffMatrixL, diffMatrixR] = multiRankActivationConstraintMatrix (G, basicParameter);
        
        updatedG =  G .* ( B' * (X .* (Xhat .^(basicParameter.beta-2) )) + 2* alpha2 * (diffMatrixL + diffMatrixR) ) ./ (B' * (Xhat .^ (basicParameter.beta-1)) + 4*alpha2*G );
    end
   
end

    
function [diffMatrixL, diffMatrixR] = multiRankActivationConstraintMatrix (G, basicParameter)
    diffMatrixL = [0 zeros(1, size(G,2)-1); zeros(size(G,1)-1,1) G(1:end-1,1:end-1) ];
    diffMatrixR = [G(2:end,2:end) zeros(size(G,1)-1,1); zeros(1, size(G,2)-1) 0];
        
    diffMatrixL( 1, :) = 0;
    diffMatrixR( 1, :) = 0;
    for i = 1: (basicParameter.maxNote - basicParameter.minNote +1) 
        diffMatrixL( (i-1) * basicParameter.rankMode + 2, :) = 0;
        diffMatrixR( (i-1) * basicParameter.rankMode + 2, :) = 0;
    end

end 