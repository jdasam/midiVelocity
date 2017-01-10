function fittingArraySMD = trainFitFolder(B, basicParameter)

dataSet = getFileListWithExtension('*.mp3');

ydataSMD = zeros(5000, 88);
xdataSMD = zeros(5000, 88);

for j = 1:length(dataSet)
    
    filename = char(dataSet(j));
    MIDIFilename = strcat(filename,'.mid');
    MP3Filename =  strcat(filename, '.mp3');

    [Gx] = velocityExtractionOption(MP3Filename, MIDIFilename, B, basicParameter);

    midiRef = readmidi_java(MIDIFilename,true);
    midiRef(:,7) = midiRef(:,7) + midiRef(:,6);

    for i = 1 : length(midiRef)
        pitch = midiRef(i,4);
        index = onsetTime2frame(midiRef(i,6), basicParameter);
        %index = ceil( ( midiRef(i,6) * basicParameter.sr - basicParameter.window /2 )/ basicParameter.nfft);
        
        dataIndex = min(find(ydataSMD(:,pitch-basicParameter.minNote+1)==0));
        if basicParameter.rankMode == 1;
            gainTemp = max(Gx(2 + pitch - basicParameter.minNote, index:index+basicParameter.searchRange));            
        elseif basicParameter.rankMode == 2;
            gainTemp = max(Gx(2 + (pitch - basicParameter.minNote) * 2,index:index+basicParameter.searchRange));
        end
        ydataSMD(dataIndex,pitch-basicParameter.minNote+1) = gainTemp;
        xdataSMD(dataIndex,pitch-basicParameter.minNote+1) = midiRef(i,5);
    end


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
