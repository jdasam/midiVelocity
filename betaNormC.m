function resultMatrix = betaNormC(inputMatrix, beta)

resultMatrix = zeros(size(inputMatrix));

if beta == 0;
    beta = 2;
end


for j = 1:size(inputMatrix,2)
    columnSum = sum ( inputMatrix(:,j) .^ beta) .^ (1/beta); 
    resultMatrix(:,j) = inputMatrix(:,j) / columnSum;
end
end