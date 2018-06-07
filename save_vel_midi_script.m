load('/Users/Da/Dropbox/midiVelocityResult/R10scaleS2Gpr5Ubn30Hb15sr04_all.mat')

filename = 'op17no4';
audioname = strcat(filename, '.wav');
midiname = strcat(filename, '.mid');
resultname = strcat(filename, '_vel.mid');

basicParameter.targetMedian = 45;
basicParameter.targetRange = 20;
basicParameter.useGPU =false;
basicParameter = updateBasicParam(basicParameter);
% basicParameter.findMaxNarrowed  = true; 
basicParameter.bExtSecond = 0;

[~,midiVel] = velocityExtractionOption(audioname, midiname, B, basicParameter);

%%
writemidi_seconds(midiVel,resultname);