function basicParameter = basicParameterInitialize()

basicParameter = [];
basicParameter.scale = 'stft';  % midi, erbt, stft
basicParameter.sr = 44100; %
basicParameter.nfft = 2048; %2048, erbt 512;
basicParameter.window =  8192; % 8192, erbt 512;
basicParameter.noverlap = basicParameter.window - basicParameter.nfft;
basicParameter.attackLengthFrame = 7;
basicParameter.searchRange = 13;
basicParameter.beta = 1;
basicParameter.MIDIFilename = 'pianoScale12Staccato2.mid';
basicParameter.defaultFolderDir = '/Users/Da/Documents/MATLAB/midiVelocityGit';
basicParameter.resultFolderDir = '/Users/Da/Dropbox/midiVelocityResult';

basicParameter.basisSource = 'scale'; %scale, data
basicParameter.alpha = 0;
basicParameter.rankMode = 1; % rank1: 88, rank2: 176
basicParameter.spectrumMode = 1; 
basicParameter.weightOnAttack = false;
basicParameter.Gfixed = false;
basicParameter.harmConstrain = false;
basicParameter.onsetFine = 0;
basicParameter.offsetFine = 0;
basicParameter.updateBnumber = 0;
basicParameter.harmBoundary = 0.5;
basicParameter.GpartialUpdate = false;
basicParameter.BpartialUpdate = false;
basicParameter.useInitialB = false;
basicParameter.GpreUpdate = 0;
basicParameter.attackExceptRange= basicParameter.attackLengthFrame;

basicParameter.minNote = 21;
basicParameter.maxNote = 108;
basicParameter.fittingArray = zeros(2,88);

basicParameter.iterationScale = 100;
basicParameter.iterationData = 100;
if basicParameter.rankMode == 1 && basicParameter.Gfixed
    basicParameter.iterationScale =5;
end



if strcmp(basicParameter.scale, 'erbt')
    basicParameter.weightOnAttack = false;
    basicParameter.rankMode = 1;
    basicParameter.sr=22050;
    basicParameter.nfft = 512; 
    basicParameter.window =  512;
end



basicParameter.map_mx = fft2midimx(basicParameter.window, basicParameter.sr, basicParameter.minNote,basicParameter.maxNote+24, 0.25);

end