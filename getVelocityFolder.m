function [] = getVelocityFolder(dirFolder, B, basicParameter, audioExtension)

cd(dirFolder);
dataSet = getFileListWithExtension(strcat('*.', audioExtension));

for dataIndex = 1 : length(dataSet)
    fileName = dataSet{dataIndex};
    velocityCSVname = strcat(fileName, '_vel.csv');

    if exist(velocityCSVname, 'file')
        continue
    end
    if strcmp(fileName, 'midi')
        continue
    end
%     fileName = 'Cortot, Alfred';
    audioFilename = strcat(fileName, '.mp3');
    MIDIFilename = strcat(fileName, '.mid');
    basicParameter.nfft = 1024;
    basicParameter.noverlap = basicParameter.window - basicParameter.nfft;
    basicParameter.searchRange = 0.5;
    % basicParameter.attackExceptRange = 14;
    basicParameter.attackLengthSecond = 0.4;
    basicParameter.attackExceptRange = 0.4;
    basicParameter.fExtSecond = 0.3;
    basicParameter.bExtSecond = 0.5;
    basicParameter.updateBnumber = 50;
    basicParameter.GpreUpdate = 5;

    basicParameter.targetMedian = 65;
    basicParameter.targetRange = 25;

    basicParameter.transcription = false;
    basicParameter.threshold = 5;
    basicParameter.rankMode = 2;
    basicParameter.alpha = 1;
    basicParameter.harmBoundary = 1;
    basicParameter.harmConstrain = true;
    basicParameter.Gfixed = true;
    basicParameter.iterationScale = 5;
    basicParameter.updateBnumber = 50;
    basicParameter.onsetFine = 0;

%     saveName = strcat(fileName, '_AMT.mid');
    [Gx, midiVel] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter);
    csvwrite(velocityCSVname, midiVel(:,5)');
    
    dirPiece = strsplit(dirFolder, 'sourceFiles');
        csvwrite(strcat( '/Users/Da/Dropbox/performScoreDemo', dirPiece{2} ,'/', velocityCSVname ), midiVel(:,5)' );
    
%     writemidi_seconds(midiVel, saveName);
end



end