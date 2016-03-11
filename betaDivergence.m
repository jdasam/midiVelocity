function D = betaDivergence(x, xhat, beta)
D = 0;    
d = 0;
if beta ==1
    for j = 1:size(x,2)
       d = x(:,j) .* log(x(:,j) ./ xhat(:,j)) - x(:,j) + xhat(:,j);
       D = D+d;
    end
elseif beta ==0
    for j = 1:size(x,2)
       d = x(:,j) / xhat(:,j) + log(x(:,j) / xhat(:,j)) -1;
       D = D+d;
    end
    
else
    for j = 1:size(x,2)
       d = (x(:,j) .^ beta + (beta - 1) * xhat(:,j) .^ beta - beta * x(:,j) .* xhat(:,j) .^ (beta -1))/ beta/ (beta-1);
       D = D+d;
    end

end