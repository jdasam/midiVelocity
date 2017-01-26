function [histData, histMIDI, f, f2]= makeHistogram(MIDIFilename, Gx, basicParameter)


midi = readmidi_java(MIDIFilename,true);
midi(:,7) = midi(:,6) + midi(:,7);


gainData = zeros(length(midi),1);


for i = 1:length(midi)

    gainData(i) = findMaxGainByNote(midi(i,:),Gx,basicParameter);

end
gainDB = 20 * log10(gainData + eps);



histData = histogram(gainDB, ceil(max(gainDB)) - floor(min(gainDB)));
f = fit(linspace(floor(min(gainDB)),ceil(max(gainDB)), ceil(max(gainDB)) - floor(min(gainDB)))', histData.Values','gauss1');
histMIDI = histogram(midi(:,5), max(midi(:,5)) - min(midi(:,5)) + 1);
f2 = fit(linspace(min(midi(:,5)),max(midi(:,5)), histMIDI.NumBins)', histMIDI.Values','gauss1');

% estimatedVelMean = 2.0163 * f.b1 - 56.3573;
% estimatedVelRange = 2.2909 * f.c1 + 2.8077;
% 
% if ~isfield(basicParameter, 'targetVelMean'); basicParameter.targetVelMean = f2.b1; end
% if ~isfield(basicParameter, 'targetVelRange'); basicParameter.targetVelRange = f2.c1; end
% 
% targetGainMean =  (basicParameter.targetVelMean + 56.3573) / 2.0163;
% targetGainRange = (basicParameter.targetVelRange - 2.8077) / 2.2909;
% compA = targetGainRange/ f.c1;
% compB = f.b1 - targetGainMean;

end