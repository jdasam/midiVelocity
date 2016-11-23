function updatedG = updateGwithTempo(G, X, Bcopy, Xhat, beta, alpha)
    
    costTplus = bsxfun(@rdivide, G*4*size(G,2), sum(G.^2, 2));
    
    rightShiftedG = [zeros(size(G,1),1) G(:,1:size(G,2)-1)];
    leftShiftedG = [G(:,2:size(G,2)) zeros(size(G,1),1)];
    
    tempTerm = bsxfun(@times, 2*size(G,2)*G, sum( (G(:,2:size(G,2))-rightShiftedG(:,2:size(G,2)) ).^2  ,2));
    
    costTminus = bsxfun(@rdivide, 2*size(G,2)+rightShiftedG+leftShiftedG, sum(G.^2,2)) + bsxfun(@rdivide, tempTerm, sum(G.^2,2).^2) ;
    updatedG = G .* ( (Bcopy' * (X .* (Xhat .^(beta-2) )) + alpha * costTplus )  ./ (Bcopy' * (Xhat .^ (beta-1))) + alpha * costTminus );


   
end