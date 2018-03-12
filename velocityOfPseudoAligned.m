function [error, numberOfNotesByError]  = velocityOfPseudoAligned(dir, Bcell, fittingArrayCell, basicParameter, titleCell)

cd(dir);

mp3filesInFolder = getFileListWithExtension('*.mp3');
pieces = {}; % list of pieces
error = zeros(6, length(titleCell));
numberOfNotesByError = zeros(127, length(titleCell));
basicParameter.usePseudoAligned = true;

for i = 1:length(mp3filesInFolder)
    if length(strsplit(mp3filesInFolder{i}, '_score')) ==1
        pieces{length(pieces)+1} = mp3filesInFolder{i};
    end
end

for i = 1:length(pieces)
    audioFilename = strcat(pieces{i}, '.mp3');
    MIDIFilename = strcat(pieces{i}, '_aligned.mid');
    textFileName = strcat(pieces{i}, '_corresp.txt');
    
    if ~exist(textFileName, 'file')
        continue
    end
    
    
    for j = 1:length(titleCell)
        if strcmp(titleCell{j}, pieces{i}) == 1
            if j <= 15
                trainingGroupIndex = 1;
                subSetIndex = floor( (j-1) /5) + 1;
            elseif j <= 21
                trainingGroupIndex = 2;
                subSetIndex = floor( (j-16) /2) + 1;               
            elseif j <=34
                trainingGroupIndex = 3;
                subSetIndex = max (floor( (j-23) /4), 0) + 1;
            else
                trainingGroupIndex = 4;
                subSetIndex = floor( (j-35) / 5)+ 1;
            end
            break
        end
    end
    
    if strcmp( class(Bcell), 'cell') == 1
        B = Bcell{trainingGroupIndex, subSetIndex};
    else
        B = Bcell;
    end
    
    basicParameter.fittingArray = fittingArrayCell{trainingGroupIndex, subSetIndex};
    
    [~, ~, error(:,j), ~, ~, ~, ~, ~, numberOfNotesByError(:,j)] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter);

end



end