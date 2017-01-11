function [B updatedG] = trainBasisFromFolder(basicParameter)

dataSet = getFileListWithExtension('*.mp3');

Xtotal = [];
sheetMatrixTotal = [];

window = basicParameter.window;
noverlap = basicParameter.noverlap;

if strcmp(basicParameter.scale, 'stft') | strcmp(basicParameter.scale, 'midi')

    for j = 1:length(dataSet)

        filename = char(dataSet(j));
        MIDIFilename = strcat(filename,'.mid');
        MP3Filename =  strcat(filename, '.mp3');

        Xtemp = audio2spectrogram(MP3Filename, basicParameter);

        Xtotal = horzcat(Xtotal, Xtemp);

        nmat = readmidi_java(MIDIFilename, true);
        nmat(:,7) = nmat(:,6) + nmat(:,7);

        sheetMatrixTemporal = midi2MatrixOption(nmat, size(Xtemp,2), basicParameter);
        sheetMatrixTotal = horzcat(sheetMatrixTotal, sheetMatrixTemporal);

    end

    [updatedG B] = basisNMFoption(Xtotal, sheetMatrixTotal, basicParameter, 100);

    
    
elseif strcmp(basicParameter.scale, 'erbt')
    for j = 1:length(dataSet)

        filename = char(dataSet(j));
        MIDIFilename = strcat(filename,'.mid');
        MP3Filename =  strcat(filename, '.mp3');

        [Xtemp, f, alen] = audio2erbt(MP3Filename, basicParameter);

        Xtotal = horzcat(Xtotal, Xtemp);

        nmat = readmidi_java(MIDIFilename, true);
        nmat(:,7) = nmat(:,6) + nmat(:,7);

        sheetMatrixTemporal = midi2MatrixOption(nmat, size(Xtemp,2), basicParameter);
        sheetMatrixTotal = horzcat(sheetMatrixTotal, sheetMatrixTemporal);

    end

    sheetMatrixTotalCopy = sheetMatrixTotal(21:end,:);
    sheetMatrixTotal = vertcat(sheetMatrixTotalCopy, sheetMatrixTotal(20,:));
    
    [updatedG B] = erbtHarmclusNMF(Xtotal, sheetMatrixTotal, false, 250,f,alen, basicParameter, false);

end
