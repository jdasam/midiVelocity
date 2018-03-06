function [Bnew,Gnew] =r2matrixToCommon(B,G)

Bnew = zeros(size(B));
Gnew = zeros(size(G));

Bnew(:,1) = B(:,1);
Gnew(1,:) = G(1,:);

for i =2: size(B,2)
    if i < 90
        Bnew(:,(i-2)*2+3) = B(:,i);
        Gnew((i-2)*2+3,:) = G(i,:);
    else
        Bnew(:,(i-90)*2+2) = B(:,i);
        Gnew((i-90)*2+2,:) = G(i,:);
        
        
    end
    
end


end