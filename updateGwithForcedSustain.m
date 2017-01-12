function updatedG = updateGwithForcedSustain(G, X, Bcopy, Xhat, beta, alpha, Attack)
    
    rightShiftedG = [zeros(size(G,1),1) G(:,1:size(G,2)-1)];
    leftShiftedG = [G(:,2:size(G,2)) zeros(size(G,1),1)];
    
    % g_t - g_(t-1)
    differenceA = G - rightShiftedG;
    % g_(t-1) - g_(t-2)
    
    differenceAbool = zeros(size(differenceA));
    differenceAbool(differenceA>0) = 1;
    differenceAbool(differenceA<0) = 0;

    Attack(Attack==0) = -1;
    Attack(Attack>0) = 0;
    
    boolMat = differenceAbool .* -Attack ;
    
    T = size(G,2);
    %sigma = sum(G.^4,2) / T;
    sigma = sum( (G.*-Attack).^2,2) / T;
    %tempCostByRow = sum(differenceA.^2 .* differenceB.^2 .* boolMat, 2);
    tempCostByRow = sum(differenceA.^2 .* boolMat, 2);

    costTplus = bsxfun(@rdivide, 2*G, sigma) .* boolMat ;
    costTminus = ( bsxfun(@rdivide, 2*rightShiftedG, sigma) + bsxfun(@rdivide,bsxfun(@times,2*T*G,tempCostByRow) ,(sum(G.^2,2)).^2) ).* boolMat;

%     costTplus = bsxfun(@rdivide, G*4*size(G,2), sum(G.^2, 2)) .* boolMat;
% 
%     tempTerm = bsxfun(@times, 2*size(G,2)*G, sum( (G(:,2:size(G,2))-rightShiftedG(:,2:size(G,2)) ).^2  ,2));
%     costTminus = (bsxfun(@rdivide, 2*size(G,2)*(rightShiftedG+leftShiftedG), sum(G.^2,2)) + bsxfun(@rdivide, tempTerm, sum(G.^2,2).^2) ).* boolMat ;

    

    updatedG = G .* ( (Bcopy' * (X .* (Xhat .^(beta-2) )) + alpha * costTminus )  ./ (Bcopy' * (Xhat .^ (beta-1)) + alpha * costTplus)    );


   
end