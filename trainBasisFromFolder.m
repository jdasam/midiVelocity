function fittingArraySMD = trainBasisFromFolder(B, basicParameter)

dataSet = getFileListWithExtension('*.mp3');

for j = 1:length(dataSet)
    
    filename = char(dataSet(j));
    MIDIFilename = strcat(filename,'.mid');
    MP3Filename =  strcat(filename, '.mp3');
    
    
    sheetMatrixTemporal = midi2Matrix();

end


fittingArraySMD = zeros(2,88);

for i = 1: 88
    if max(find(xdataSMD(:,i))) > 5
        dataSize = min(find(xdataSMD(:,i)==0)) -1;
        [lassoAll, stats] = lasso(xdataSMD(1:max(find(xdataSMD(:,i))),i), log(ydataSMD(1:max(find(xdataSMD(:,i))),i)), 'CV', 5);
        fittingArraySMD(:, i) = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];
    end
end


%
fitMin = min(find(fittingArraySMD(1,:)));
fitMax = max(find(fittingArraySMD(1,:)));


for j = 1:88
    if fittingArraySMD(1,j) == 0
        if j < fitMin
           fittingArraySMD(:,j) =  fittingArraySMD(:,fitMin);
        else
           fittingArraySMD(:,j) =  fittingArraySMD(:,fitMax);
        end
    end
end

end
