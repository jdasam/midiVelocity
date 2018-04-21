function [error, refVelCompare, fittingArray, xdata, ydata, gainCompareVec] = velocityFastTest(filename, basicParameter)

    B= initializeWwithHarmonicConstraint(basicParameter);
    if basicParameter.softConstraint
        B = rand(size(B));
    end
    MIDIFilename = strcat(filename,'.mid');
    MP3Filename =  strcat(filename, '.mp3');
    txtFilename = strcat(filename, '_pedal.txt');
    
    ydata = zeros(1000, 88);
    xdata = zeros(1000, 88);
    

    [G, ~,~,~,~,~,~, B] = velocityExtractionOption(MP3Filename, MIDIFilename, B, basicParameter, txtFilename);

    midiRef = readmidi_java(MIDIFilename,true);
    midiRef(:,7) = midiRef(:,7) + midiRef(:,6);

    for i = 1 : length(midiRef)
        basisIndex = midiRef(i,4) - basicParameter.minNote +2;
        
        [gainTemp] = findMaxGainByNote(midiRef(i,:), G, basicParameter, B, midiRef);
        
        dataIndex = min(find(ydata(:,basisIndex-1)==0));
        
        ydata(dataIndex,basisIndex-1) = gainTemp;
        xdata(dataIndex,basisIndex-1) = midiRef(i,5);

    end
    
    fittingArray = zeros(2,88);

    for i = 1: 88
        if max(find(xdata(:,i))) > 5
            dataSize = min(find(xdata(:,i)==0)) -1;
            [lassoAll, stats] = lasso(xdata(1:max(find(xdata(:,i))),i), log(ydata(1:max(find(xdata(:,i))),i)), 'CV', 5);
            fittingArray(:, i) = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];
        end
    end
    
    midiVel = midiRef;
    gainFromVelVec = zeros(size(midiVel,1),1);
    gainCalculatedVec = zeros(size(midiVel,1),1);
    gainCompareVec = zeros(size(midiVel,1),2);
    
    for i = 1:length(midiVel)
        
        basisIndex = max(midiVel(i,4),21) - basicParameter.minNote + 2;

        [gainCalculated] = findMaxGainByNote(midiVel(i,:), G, basicParameter, B, midiVel);
        
      

        coefA = fittingArray(1, basisIndex-1);
        coefB = fittingArray(2, basisIndex-1);


%         logGainFromVel = exp(midiVel(i,5) * coefA + coefB);
        logGainFromVel = exp(midiRef(i,5) * coefA + coefB);
        

        midiVel(i,5) = round(  ( log(gainCalculated) - coefB ) / coefA);    
        gainFromVelVec(i) = logGainFromVel ^0.6;
        gainCalculatedVec(i) = gainCalculated ^0.6;

        %midiVel(i,5) = round(sqrt(max(Gx(pitch,index:index))) * 2.5);
        if midiVel(i,5) < 0
            midiVel(i,5) = 1;
        end
        if midiVel(i,5) > 127
            midiVel(i,5) = 127;
        end            
    end
    [error, errorPerNoteResult, refVelCompare, numberOfNotesByError] = calculateError(midiRef, midiVel, gainFromVelVec, gainCalculatedVec);
    gainCompareVec(:,1) = gainFromVelVec;
    gainCompareVec(:,2) = gainCalculatedVec;
    
end


function [xdata, ydata, xdataCluster, ydataCluster] = folderNMF(dir, xdata, ydata, B, basicParameter, xdataCluster, ydataCluster)


    
    filename = char(dataSet(j));
    MIDIFilename = strcat(filename,'.mid');
    MP3Filename =  strcat(filename, '.mp3');
    txtFilename = strcat(filename, '_pedal.txt');

    G = velocityExtractionOption(MP3Filename, MIDIFilename, B, basicParameter, txtFilename);

    midiRef = readmidi_java(MIDIFilename,true);
    midiRef(:,7) = midiRef(:,7) + midiRef(:,6);

    for i = 1 : length(midiRef)
        basisIndex = midiRef(i,4) - basicParameter.minNote +2;
        
        [gainTemp, ~,~,~,onsetClusterData] = findMaxGainByNote(midiRef(i,:), G, basicParameter, B, midiRef);

%         
        dataIndex = min(find(ydata(:,basisIndex-1)==0));
        
        ydata(dataIndex,basisIndex-1) = gainTemp;
        xdata(dataIndex,basisIndex-1) = midiRef(i,5);
        
        if length(onsetClusterData) > 0
            dataIndexCluster = min(find(xdataCluster(:,basisIndex-1)==0));
            ydataCluster{dataIndexCluster, basisIndex-1} = onsetClusterData;
            xdataCluster(dataIndexCluster, basisIndex-1) = midiRef(i,5);
        end
    end

end