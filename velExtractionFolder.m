function resultData = velExtractionFolder(dir, B, basicParameter, resultData)

cd(dir)


dataSet = getFileListWithExtension('*.mp3');
for i=1:length(dataSet)
    filename = char(dataSet(i));
    MIDIFilename = strcat(filename,'.mid');
    MP3Filename =  strcat(filename, '.mp3');

    [Gx, midiVel, tempError, tempErrorByNote, tempCompare] = velocityExtractionOption(MP3Filename, MIDIFilename, B, basicParameter);

    resultData.errorByNote{size(resultData.errorByNote,2)+1} = tempErrorByNote(:, basicParameter.minNote:length(tempErrorByNote)) ;
    resultData.compareRefVel{size(resultData.compareRefVel,2)+1} = tempCompare;
    resultData.title(size(resultData.title,1)+1,:) = cellstr(filename);
    resultData.error(:,size(resultData.error,2)+1) = tempError;
end


end