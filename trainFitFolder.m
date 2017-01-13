function fittingArray = trainFitFolder(B, basicParameter, dir)

if nargin<3
   dir = pdw; 
end

if ischar(dir)
    dirCell={};
    dirCell{1}=dir;
    dir = dirCell;
end


ydata = zeros(10000, 88);
xdata = zeros(10000, 88);


for i = 1:length(dir)
    tempDir = dir{i};
    [xdata, ydata] = folderNMF(tempDir, xdata, ydata, B, basicParameter);
end



fittingArray = zeros(2,88);

for i = 1: 88
    if max(find(xdata(:,i))) > 5
        dataSize = min(find(xdata(:,i)==0)) -1;
        [lassoAll, stats] = lasso(xdata(1:max(find(xdata(:,i))),i), log(ydata(1:max(find(xdata(:,i))),i)), 'CV', 5);
        fittingArray(:, i) = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];
    end
end


%
fitMin = min(find(fittingArray(1,:)));
fitMax = max(find(fittingArray(1,:)));


for j = 1:88
    if fittingArray(1,j) == 0
        if j < fitMin
           fittingArray(:,j) =  fittingArray(:,fitMin);
        else
           fittingArray(:,j) =  fittingArray(:,fitMax);
        end
    end
end

end

function [xdata, ydata] = folderNMF(dir, xdata, ydata, B, basicParameter)

cd(dir);
dataSet = getFileListWithExtension('*.mp3');

for j = 1:length(dataSet)
    
    filename = char(dataSet(j));
    MIDIFilename = strcat(filename,'.mid');
    MP3Filename =  strcat(filename, '.mp3');

    [Gx] = velocityExtractionOption(MP3Filename, MIDIFilename, B, basicParameter);

    midiRef = readmidi_java(MIDIFilename,true);
    midiRef(:,7) = midiRef(:,7) + midiRef(:,6);

    for i = 1 : length(midiRef)
        basisIndex = midiRef(i,4) - basicParameter.minNote +2;
        index = onsetTime2frame(midiRef(i,6), basicParameter);
        
        indexEnd = index + basicParameter.searchRange;
        if indexEnd > size(Gx,2)
            indexEnd = size(Gx,2);
        end
        
        %index = ceil( ( midiRef(i,6) * basicParameter.sr - basicParameter.window /2 )/ basicParameter.nfft);
        
        dataIndex = min(find(ydata(:,basisIndex-1)==0));
        gainTemp = max(Gx(basisIndex, index:indexEnd)); 

        ydata(dataIndex,basisIndex-1) = gainTemp;
        xdata(dataIndex,basisIndex-1) = midiRef(i,5);
    end
end
end