function updatedG = updateGwithVshape(G, X, Bcopy, Xhat, beta, alpha)
    
    rightShiftedG = [zeros(size(G,1),1) G(:,1:size(G,2)-1)];
    leftShiftedG = [G(:,2:size(G,2)) zeros(size(G,1),1)];
    right2ShiftedG = [zeros(size(G,1),2) G(:,1:size(G,2)-2)];
    left2ShiftedG = [G(:,3:size(G,2)) zeros(size(G,1),2)];
    
    % g_t - g_(t-1)
    differenceA = G - rightShiftedG;
    % g_(t-1) - g_(t-2)
    differenceB = rightShiftedG - right2ShiftedG;
    
    differenceAbool = zeros(size(differenceA));
    differenceAbool(differenceA>0) = 1;
    differenceAbool(differenceA<0) = 0;
    differenceBbool = zeros(size(differenceB));
    
    % if differenceB < 0
    differenceBbool(differenceB<0) = 1;
    differenceBbool(differenceB>0) = 0;    

    boolMat = differenceAbool .* differenceBbool;
    
    T = size(G,2);
    %sigma = sum(G.^4,2) / T;
    sigma = sum(G.^2,2) / T;
    %tempCostByRow = sum(differenceA.^2 .* differenceB.^2 .* boolMat, 2);
    tempCostByRow = sum(differenceA.^2 .* boolMat, 2);

    costTplus = bsxfun(@rdivide, 2*G, sigma) .* boolMat ;
    costTminus = ( bsxfun(@rdivide, 2*rightShiftedG, sigma) + bsxfun(@rdivide,bsxfun(@times,2*T*G,tempCostByRow) ,(sum(G.^2,2)).^2) ).* boolMat;
    
%     %diffPlusTerm = 4 * rightShiftedG.^2 .* G  + 2*right2ShiftedG.^2.*G + 4*right2ShiftedG.*rightShiftedG.^2 + 4*G.*leftShiftedG.^2 + 4*G.^3 + 8*rightShiftedG.*G.*leftShiftedG + 2*G.*left2ShiftedG.^2 + 4*leftShiftedG.^2.*left2ShiftedG;
%     diffPlusTerm = 2*rightShiftedG.^2 .* G  + 2*right2ShiftedG.^2.*G + 4*right2ShiftedG.*rightShiftedG.^2;
%     %diffMinusTerm = 2*rightShiftedG.^3 + 2*right2ShiftedG.^2.*rightShiftedG + 4*right2ShiftedG.*rightShiftedG.*G + 6*G.^2.*leftShiftedG + 2*rightShiftedG.^2.*leftShiftedG + 2*rightShiftedG.*leftShiftedG.^2 + 6*rightShiftedG.*G.^2 + 4*G.*leftShiftedG.*left2ShiftedG + 2*leftShiftedG.*left2ShiftedG.^2 + 2*leftShiftedG.^3;
%     diffMinusTerm = 2*rightShiftedG.^3 + 2*right2ShiftedG.^2.*rightShiftedG + 4*right2ShiftedG.*rightShiftedG.*G;
%     
%     sigmaMinusTerm = bsxfun(@times, 4*G.^3, tempCostByRow);
%     
% 
%     costTplus = bsxfun(@rdivide, diffPlusTerm, sigma) .* boolMat;
%     costTminus = (bsxfun(@rdivide, diffMinusTerm, sigma) + bsxfun(@rdivide, sigmaMinusTerm, sum(G.^4,2).^2)/T ) .* boolMat;


    updatedG = G .* ( (Bcopy' * (X .* (Xhat .^(beta-2) )) + alpha * costTminus )  ./ (Bcopy' * (Xhat .^ (beta-1)) + alpha * costTplus)    );


   
end