function [fittingArray, velocityGainMatchingData] = trainFitFolder(B, basicParameter, dir)

if nargin<3
   dir = pwd; 
end

if ischar(dir)
    dirCell={};
    dirCell{1}=dir;
    dir = dirCell;
end
    
basicParameter.fittingArray = zeros(2,88);

ydata = zeros(10000, 88);
xdata = zeros(10000, 88);

xdataCluster = zeros(10000,88);
ydataCluster = {};


for i = 1:length(dir)
    tempDir = dir{i};
    [xdata, ydata, xdataCluster, ydataCluster] = folderNMF(tempDir, xdata, ydata, B, basicParameter, xdataCluster, ydataCluster);
end
% 
% maxData = 0;
% for i = 1:88
%     tempMaxData = max(find(xdata(:,i)));
%     if tempMaxData > maxData
%         maxData = tempMaxData;
%     end
% end

if size(ydataCluster,1) > 1 
    xdata(size(ydataCluster,1)+1:end,:) = [];
    ydata(size(ydataCluster,1)+1:end,:) = [];
    xdataCluster(size(ydataCluster,1)+1:end,:) = [];
end


velocityGainMatchingData ={xdata, ydata, xdataCluster, ydataCluster};

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
        elseif j> fitMax
           fittingArray(:,j) =  fittingArray(:,fitMax);
        else
           fittingArray(:,j) = fittingArray(:, j-1);
        end
        
    end
end





end

function [xdata, ydata, xdataCluster, ydataCluster] = folderNMF(dir, xdata, ydata, B, basicParameter, xdataCluster, ydataCluster)

cd(dir);
dataSet = getFileListWithExtension(strcat('*',basicParameter.audioExtension));

if isfield(basicParameter, 'fExtSecond')
    if basicParameter.fExtSecond
        basicParameter.fExt = ceil(basicParameter.fExtSecond / basicParameter.nfft * basicParameter.sr); % forward Extension
        basicParameter.bExt = ceil(basicParameter.bExtSecond / basicParameter.nfft * basicParameter.sr); % backward Extnsion
        basicParameter.attackLengthSecond = basicParameter.attackLengthSecond + basicParameter.fExtSecond;
    end
end

for j = 1:length(dataSet)
    
    filename = char(dataSet(j));
    MIDIFilename = strcat(filename, basicParameter.midiExtension);
    MP3Filename =  strcat(filename, basicParameter.audioExtension);
    txtFilename = strcat(filename, '_pedal.txt');

    [G, ~,~,~,~,~,~, Bupdated] = velocityExtractionOption(MP3Filename, MIDIFilename, B, basicParameter, txtFilename);

    midiRef = readmidi_java(MIDIFilename,true);
    midiRef(:,7) = midiRef(:,7) + midiRef(:,6);

    for i = 1 : length(midiRef)
        basisIndex = midiRef(i,4) - basicParameter.minNote +2;
        
        if basicParameter.saveOnsetCluster
            [gainTemp, ~,~,~,onsetClusterData] = findMaxGainByNote(midiRef(i,:), G, basicParameter, Bupdated,midiRef);
            
            if length(onsetClusterData) > 0
                dataIndexCluster = min(find(xdataCluster(:,basisIndex-1)==0));
                ydataCluster{dataIndexCluster, basisIndex-1} = onsetClusterData;
                xdataCluster(dataIndexCluster, basisIndex-1) = midiRef(i,5);
            end
        else
            gainTemp = findMaxGainByNote(midiRef(i,:), G, basicParameter, Bupdated, midiRef);
        end
            
            
%         index = onsetTime2frame(midiRef(i,6), basicParameter);
%         offset = ceil( (midiRef(i,7) * basicParameter.sr) / basicParameter.nfft) + basicParameter.offsetFine;
% 
%         indexEnd = index + basicParameter.searchRangeFrame;
%         
%         if indexEnd > offset
%             indexEnd = offset;
%         end
% 
%         if indexEnd > size(Gx,2)
%             indexEnd = size(Gx,2);
%         end
% 
% 
%         %index = ceil( ( midiRef(i,6) * basicParameter.sr - basicParameter.window /2 )/ basicParameter.nfft);
%         
%         
%         
        dataIndex = min(find(ydata(:,basisIndex-1)==0));
%         gainTemp = max(Gx(basisIndex, index:indexEnd)); 
        
        ydata(dataIndex,basisIndex-1) = gainTemp;
        xdata(dataIndex,basisIndex-1) = midiRef(i,5);

    end
end
end