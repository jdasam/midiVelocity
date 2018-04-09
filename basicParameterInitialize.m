function basicParameter = basicParameterInitialize()


basicParameter = [];
basicParameter.scale = 'stft';  % midi, erbt, stft
basicParameter.sr = 44100; %
basicParameter.nfft = 2048; %2048, erbt 512;
basicParameter.window =  8192; % 8192, erbt 512;
% basicParameter.attackLengthFrame = 7;
basicParameter.attackLengthSecond = 0.25;
% basicParameter.searchRange = 13;
basicParameter.searchRangeSecond = 0.8;
basicParameter.multiRankOverlapSecond = 0.15;
basicParameter.multiRankHopSecond = 0.0464;
basicParameter.onsetWindowSecond = 0.3;

basicParameter.beta = 1;
basicParameter.MIDIFilename = 'pianoScale12Staccato2.mid';
basicParameter.defaultFolderDir = '/Users/Da/Documents/MATLAB/midiVelocityGit';
basicParameter.resultFolderDir = '/Users/Da/Dropbox/midiVelocityResult';
basicParameter.saveOnsetCluster = false;

basicParameter.basisSource = 'scale'; %scale, data
basicParameter.alpha = 0;
basicParameter.alpha1= 0;
basicParameter.alpha2 = 0;
basicParameter.alpha3 = 0;
basicParameter.alpha4 = 0;
basicParameter.beta1 = 0;
basicParameter.beta2 = 0;
basicParameter.beta3 = 0;
basicParameter.gamma = 0;
basicParameter.rankMode = 1; % rank1: 88, rank2: 176
basicParameter.spectrumMode = 1; 
basicParameter.weightOnAttack = false;
basicParameter.Gfixed = false;
basicParameter.harmConstrain = true;
basicParameter.onsetFine = 0;
basicParameter.offsetFine = 0;
basicParameter.updateBnumber = 0;
basicParameter.harmBoundary = 1;
basicParameter.GpartialUpdate = false;
basicParameter.BpartialUpdate = false;
basicParameter.useInitialB = false;
basicParameter.GpreUpdate = 0;
% basicParameter.attackExceptRange= basicParameter.attackLengthFrame;
basicParameter.attackExceptRange= basicParameter.attackLengthSecond;
basicParameter.softConstraint = false;
basicParameter.saveMIDI = false;

basicParameter.postUpdate = false;

basicParameter.fExtSecond = 0;
basicParameter.bExtSecond = 0;

basicParameter.minNote = 21;
basicParameter.maxNote = 108;
basicParameter.fittingArray = zeros(2,88);

basicParameter.iterationScale = 100;
basicParameter.iterationData = 50;
basicParameter.iterationPiece = 50;
if basicParameter.rankMode == 1 && basicParameter.Gfixed
    basicParameter.iterationScale =5;
end
basicParameter.iterationPost = 15;

basicParameter.usePedal = false;
basicParameter.pedalThreshold = 50;

basicParameter.audioExtension = '.mp3';
basicParameter.midiExtension = '.mid';
basicParameter.mapmxResolution = 0.25;


if strcmp(basicParameter.scale, 'erbt')
    basicParameter.weightOnAttack = false;
    basicParameter.rankMode = 1;
    basicParameter.sr=22050;
    basicParameter.nfft = 512; 
    basicParameter.window =  512;
end


basicParameter.map_mx = fft2midimx(basicParameter.window, basicParameter.sr, basicParameter.minNote,basicParameter.maxNote+24, basicParameter.mapmxResolution);


basicParameter.noverlap = basicParameter.window - basicParameter.nfft;
basicParameter.searchRangeFrame = ceil(basicParameter.searchRangeSecond / basicParameter.nfft * basicParameter.sr);
basicParameter.multiRankOverlapFrame = ceil(basicParameter.multiRankOverlapSecond / basicParameter.nfft * basicParameter.sr);
basicParameter.multiRankHopFrame = ceil(basicParameter.multiRankHopSecond / basicParameter.nfft * basicParameter.sr);
end