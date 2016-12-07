function [fittingArray, errorByNote, ydata, nmatTest] = fittingByNote(Gtest, xdata, basicParameter)

nmat = basicParameter.MIDI;
ydata = zeros(basicParameter.velMod, basicParameter.maxNote - basicParameter.minNote +1);
GtestSum = sum(Gtest,1);


for i = 1: basicParameter.maxNote - basicParameter.minNote +1
    velIndex = 1;
    for j = (i-1)*basicParameter.velMod + 1: i*basicParameter.velMod
        index =  ceil( ( nmat(j,6) * basicParameter.sr - basicParameter.window/2)  / basicParameter.nfft);
         
        pianoKeyInMatrix = 2 +  (nmat(j,4) - basicParameter.minNote) * 2;
        %pianoKeyInMatrix = nmat(j,4) - (basicParameter.minNote - 2);
        %index = ceil( ( nmat(j,6) *basicParameter.sr - basicParameter.window /2 )/ basicParameter.hopSize) + 1;
        
        if index < 1
            index = 1;
        end
        %ydata(velIndex,i) = max( GtestSum(1, index:index+3) );
        ydata(velIndex,i) = max( Gtest(pianoKeyInMatrix,index:index+4));
        
        velIndex = velIndex + 1;
    end
    
end


fitType=fittype('(a*x+b)');

fittingArray = zeros(3, basicParameter.maxNote - basicParameter.minNote +1); % a, b, rsquare


for i = 1: basicParameter.maxNote - basicParameter.minNote +1
    [fit1, gof] = fit(xdata, log(ydata(:,i)), fitType , 'StartPoint', [1 1]);
    fittingArray(:, i) = [fit1.a; fit1.b; gof.rsquare];

end

% save velocity into midi array


nmatTest = nmat;
gainDataScale = zeros(1, length(nmatTest));
%

for i = 1:length(nmatTest)
    index = floor( nmatTest(i,6) * basicParameter.sr / basicParameter.nfft) + 1;
    pianoKeyInMatrix = 2 +  (nmatTest(i,4) - basicParameter.minNote) * 2;
    gainCalculated = max(Gtest(pianoKeyInMatrix,index:index+1));
    %index = ceil( ( nmatTest(i,6) *basicParameter.sr - basicParameter.window /2 )/ basicParameter.hopSize) + 1;
    if index < 1
         index = 1;
    end
    %gainCalculated = max(Gtest(pianoKeyInMatrix,index:index+3));
    gainDataScale(i) = log(gainCalculated);
    coefA = fittingArray(1,pianoKeyInMatrix/2);
    coefB = fittingArray(2,pianoKeyInMatrix/2);

    
    nmatTest(i,5) = round( (log(gainCalculated) - coefB) / coefA);
    %nmatTest(i,5) = round(sqrt(max(Gtest(pianoKeyInMatrix,index:index+1))) * 2);
    if nmatTest(i,5) <= 0
        nmatTest(i,5) = 1;
    end
end

% calculate error
errorMatrix = zeros(length(nmatTest),2);

for i = 1: length(nmatTest)
    errorMatrix(i) = nmat(i,4)-20;
    errorMatrix(i,2) = abs(nmat(i,5) - nmatTest(i,5)) / nmat(i,5);
end

error = sum(errorMatrix) / length(errorMatrix)


errorPerNote = zeros(2, max(errorMatrix(:,1)));


for i = 1 : length(errorMatrix)
    errorPerNote(1,errorMatrix(i,1)) = errorPerNote(1,errorMatrix(i,1)) + errorMatrix(i,2);
    errorPerNote(2,errorMatrix(i,1)) = errorPerNote(2,errorMatrix(i,1)) + 1;
end


errorByNote = errorPerNote(1,:) ./ errorPerNote(2,:);



intensityRef = betaNormC(nmat(:,5),2);
intensityVel = betaNormC(gainDataScale',2);


normalizedError = sum( abs( intensityRef - intensityVel) ./ intensityRef ) / length(intensityRef)


end

