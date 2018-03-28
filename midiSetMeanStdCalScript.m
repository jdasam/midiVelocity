tempMean = 0;
tempStd = 0;

for i=1:34 %length(resultData.title)
    tempMean = tempMean + resultData.histogramData{1,i}.f2.b1;
    tempStd = tempStd +  resultData.histogramData{1,i}.f2.c1;
    
end


tempMean = tempMean/34
tempStd = tempStd/34