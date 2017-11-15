function D = betaDivergenceMatrix(x, xhat, beta)
D = 0;    
if beta ==1
    D = x .* log(x./xhat) - x + xhat;
elseif beta ==0
    D = x ./ xhat + log(x./xhat) - 1;
else
    D = (x .^ beta + (beta-1) * xhat .^ beta - beta * x .* xhat .^ (beta-1)) / beta / (beta-1);
end


D = sum(sum(D));

end