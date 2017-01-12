function updatedG = updateGwithTempoExceptAttack(G, X, Bcopy, Xhat, beta, alpha, Attack)
    
    Attack(Attack==0) = -1;
    Attack(Attack>0) = 0;
    
    T = size(G,2);
    sumRow = sum((G.*-Attack).^2,2);
    
    costTplus = bsxfun(@rdivide, G*4*size(G,2), sumRow)  .* -Attack;
    
    rightShiftedG = [zeros(size(G,1),1) G(:,1:size(G,2)-1)];
    leftShiftedG = [G(:,2:size(G,2)) zeros(size(G,1),1)];
    
    tempTerm = bsxfun(@times, 2*T*G, sum( ( (G(:,2:T)-rightShiftedG(:,2:T) ) .* -Attack(:,2:T) ) .^2  ,2)) ;
    
    costTminus = ( bsxfun(@rdivide, 2*T*(rightShiftedG+leftShiftedG), sumRow) + bsxfun(@rdivide, tempTerm, sumRow.^2)) .*-Attack;
    costTplus(find(isnan(costTplus))) = 0;
    costTminus(find(isnan(costTminus))) = 0;
    
    
    updatedG = G .* ( (Bcopy' * (X .* (Xhat .^(beta-2) )) + alpha * costTminus )  ./ (Bcopy' * (Xhat .^ (beta-1)) + alpha * costTplus) );


   
end