function [B updatedG] = trainBasisFromFolder(basicParameter, dir, initialB)

if nargin<2
   dir = pwd; 
end

if nargin<3
    initialB = false;
end

if ischar(dir)
    dirCell={};
    dirCell{1}=dir;
    dir = dirCell;
end


Xtotal = [];
sheetMatrixTotal = [];
sheetMatrixAttack = [];

window = basicParameter.window;
noverlap = basicParameter.noverlap;

if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
    
    for i = 1:length(dir)
        tempDir = dir{i};
        [Xtotal, sheetMatrixTotal, sheetMatrixAttack] = dataPrepFolder(tempDir, Xtotal, sheetMatrixTotal, sheetMatrixAttack, basicParameter);
    end

    [updatedG B] = basisNMFoption(Xtotal, sheetMatrixTotal, basicParameter, basicParameter.iterationData, false, sheetMatrixAttack, initialB, 'data');

    
    
elseif strcmp(basicParameter.scale, 'erbt')
    
    for i = 1:length(dir)
        tempDir = dir{i};
        [Xtotal, sheetMatrixTotal, sheetMatrixAttack, f, alen] = dataPrepFolder(tempDir, Xtotal, sheetMatrixTotal, sheetMatrixAttack, basicParameter);
    end

    sheetMatrixTotalCopy = sheetMatrixTotal(2:end,:);
    sheetMatrixTotal = vertcat(sheetMatrixTotalCopy, sheetMatrixTotal(1,:));
    sheetMatrixAttack = vertcat(sheetMatrixAttack(2:end,:), sheetMatrixAttack(1,:));
    

    [updatedG B] = erbtHarmclusNMF(Xtotal, sheetMatrixTotal, false, 250,f,alen, basicParameter, false, sheetMatrixAttack);

end

end


function [Xtotal, sheetMatrixTotal, sheetMatrixAttack, f, alen] = dataPrepFolder(dir, Xtotal, sheetMatrixTotal, sheetMatrixAttack, basicParameter)
cd(dir)
dataSet = getFileListWithExtension('*.mp3');

    for j = 1:length(dataSet)
        filename = char(dataSet(j));
        MIDIFilename = strcat(filename,'.mid');
        MP3Filename =  strcat(filename, '.mp3');

        if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
            Xtemp = audio2spectrogram(MP3Filename, basicParameter);
        elseif strcmp(basicParameter.scale, 'erbt')
            [Xtemp, f, alen] = audio2erbt(MP3Filename, basicParameter);
        end

        Xtotal = horzcat(Xtotal, Xtemp);

        nmat = readmidi_java(MIDIFilename, true);
        nmat(:,7) = nmat(:,6) + nmat(:,7);

        sheetMatrixTemporal = midi2MatrixOption(nmat, size(Xtemp,2), basicParameter, false, true);
        sheetMatrixAttackTemp = midi2MatrixOption(nmat, size(Xtemp,2), basicParameter, true, false);
        sheetMatrixTotal = horzcat(sheetMatrixTotal, sheetMatrixTemporal);
        sheetMatrixAttack = horzcat(sheetMatrixAttack, sheetMatrixAttackTemp);
    end

end