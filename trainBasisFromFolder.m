function [B, updatedG] = trainBasisFromFolder(basicParameter, dir, initialB)

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

if initialB ==false
    initialB = initializeWwithHarmonicConstraint(basicParameter);
    if basicParameter.softConstraint == true
        initialB= rand(size(initialB));
    end
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

%     [updatedG, B] = basisNMFoption(Xtotal, sheetMatrixTotal, basicParameter, basicParameter.iterationData, false, sheetMatrixAttack, initialB, 'data');
    if basicParameter.softConstraint == true
        Gtotal = rand(size(sheetMatrixTotal));
    else
        Gtotal = sheetMatrixTotal;
    end
    basicParameter.updateBnumber = basicParameter.iterationData;
    [updatedG, B] = NMFwithMatrix(Gtotal, initialB, Xtotal, basicParameter, basicParameter.iterationData, sheetMatrixTotal, sheetMatrixAttack);
    
    
elseif strcmp(basicParameter.scale, 'erbt')
    
    for i = 1:length(dir)
        tempDir = dir{i};
        [Xtotal, sheetMatrixTotal, sheetMatrixAttack, f, alen] = dataPrepFolder(tempDir, Xtotal, sheetMatrixTotal, sheetMatrixAttack, basicParameter);
    end

    sheetMatrixTotalCopy = sheetMatrixTotal(2:end,:);
    sheetMatrixTotal = vertcat(sheetMatrixTotalCopy, sheetMatrixTotal(1,:));
    sheetMatrixAttack = vertcat(sheetMatrixAttack(2:end,:), sheetMatrixAttack(1,:));
    

    [updatedG, B] = erbtHarmclusNMF(Xtotal, sheetMatrixTotal, false, 250,f,alen, basicParameter, false, sheetMatrixAttack);

end

end


function [Xtotal, sheetMatrixTotal, sheetMatrixAttack, f, alen] = dataPrepFolder(dir, Xtotal, sheetMatrixTotal, sheetMatrixAttack, basicParameter)
cd(dir)
dataSet = getFileListWithExtension(strcat('*',basicParameter.audioExtension));

    for j = 1:length(dataSet)
        filename = char(dataSet(j));
        MIDIFilename = strcat(filename, basicParameter.midiExtension);
        MP3Filename =  strcat(filename, basicParameter.audioExtension);
        txtFilename = strcat(filename, '_pedal.txt');

        if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')
            Xtemp = audio2spectrogram(MP3Filename, basicParameter);
        elseif strcmp(basicParameter.scale, 'erbt')
            [Xtemp, f, alen] = audio2erbt(MP3Filename, basicParameter);
        end

        Xtotal = horzcat(Xtotal, Xtemp);

        nmat = readmidi_java(MIDIFilename, true);
        nmat(:,7) = nmat(:,6) + nmat(:,7);
        
        nmat = applyPedalTxt(nmat, txtFilename, basicParameter);
        
        if basicParameter.rankMode <= 2
            sheetMatrixTemporal = midi2MatrixOption(nmat, size(Xtemp,2), basicParameter, false, basicParameter.weightOnAttack);
            sheetMatrixTotal = horzcat(sheetMatrixTotal, sheetMatrixTemporal);
            sheetMatrixAttackTemp = midi2MatrixOption(nmat, size(Xtemp,2), basicParameter, true, false);
            sheetMatrixAttack = horzcat(sheetMatrixAttack, sheetMatrixAttackTemp);
        else
            sheetMatrixTemporal = midi2MatrixOption(nmat, size(Xtemp,2), basicParameter);
            sheetMatrixTotal = horzcat(sheetMatrixTotal, sheetMatrixTemporal);
            sheetMatrixAttack = zeros(size(sheetMatrixTotal));
        end
    end

end