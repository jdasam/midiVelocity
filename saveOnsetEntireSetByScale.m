function []  = saveOnsetEntireSetByScale(dir, B ,basicParameter)

cd(dir);

mp3filesInFolder = getFileListWithExtension(strcat('*', basicParameter.audioExtension));
pieces = {}; % list of pieces


for i = 1:length(mp3filesInFolder)
    if length(strsplit(mp3filesInFolder{i}, '_score')) ==1
        pieces{length(pieces)+1} = mp3filesInFolder{i};
    end
end

for i = 1:length(pieces)
    audioFilename = strcat(pieces{i}, basicParameter.audioExtension);
    MIDIFilename = strcat(pieces{i}, basicParameter.midiExtension);
    textFilename = strcat(pieces{i}, '_corresp.txt');
    txtFilename = strcat(pieces{i}, '_pedal.txt');
    matFilename = strcat(audioFilename, '.mat');
    
    if exist(matFilename, 'file')
        continue
    end
   
    
%     basicParameter.fittingArray = fittingArrayCell{trainingGroupIndex, subSetIndex};
    
    velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter, txtFilename);

end



end