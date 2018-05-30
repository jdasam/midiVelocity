load('/Users/Da/Dropbox/midiVelocityResult/R10scaleS2Gpr5Ubn30Hb15sr04_all.mat')

filename = 'Cho-chopin-10-1';
audioname = strcat(filename, '.mp3');
midiname = strcat(filename, '_aligned_Afa.mid');
resultname = strcat(filename, '_vel_Afa.mid');

basicParameter.targetMedian = 65;
basicParameter.targetRange = 12;
basicParameter.useGPU =false;
basicParameter = updateBasicParam(basicParameter);
% basicParameter.findMaxNarrowed  = true; 
basicParameter.bExtSecond = 0.5;

[~,midiVel] = velocityExtractionOption(audioname, midiname, B, basicParameter);

%%
writemidi_java(midiVel,resultname, 120,120);