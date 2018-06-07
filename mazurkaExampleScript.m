midiname = 'op17no4.mid';
wavname = 'op17no4.wav';

midiMat = readmidi_java(midiname);
midiMat(:,7) = midiMat(:,7) + midiMat(:,6);

velMat = readmidi_java('op17no4_vel.mid');
velMat(:,7) = velMat(:,7) + velMat(:,6);

X = audio2spectrogram(wavname, basicParameter);

%%
tempParam = basicParameter;
tempParam.rankMode = 1;
tempParam.nfft = 441;
tempParam.offsetFine = -30;
sheetMatrix = midi2MatrixOption(midiMat, size(X,2), tempParam, false, false, true);

velMatrix = midi2MatrixOption(velMat, size(X,2), tempParam, false, false, true);

%
x1= 1;
x2= 3000;
y1 = 30;
y2 = 60;
boundary = 30;
boundary2 = 70;
red_hot = [linspace(1,0.9,boundary)', linspace(1,0.9,boundary)', linspace(1,0.9,boundary)'; linspace(0.9,0.7,boundary2-boundary)', linspace(0.9,0.6,boundary2-boundary)', linspace(0.9,0,boundary2-boundary)'; linspace(0.7,0.6,128-boundary2)', linspace(0.6,0,128-boundary2)', linspace(0,0,128-boundary2)']; 
colormap(red_hot);

subplot(2,1,1)
imagesc(sheetMatrix(y1:y2,x1:x2))
axis xy
ylabel('MIDI Pitch', 'FontSize', 30)
set(gca, 'XTickLabel', [0:5:30], 'XTick', [0:500:3000], 'YTickLabel', [y1:10:y2],'YTick', [0:10:y2-y1], 'FontSize', 25)
title('(a) Beat-level Estimation', 'FontSize', 30)
colorbar


subplot(2,1,2)
imagesc(velMatrix(y1:y2,x1:x2))
axis xy

xlabel('Time (seconds)', 'FontSize', 30)
ylabel('MIDI Pitch', 'FontSize', 30)
set(gca, 'XTickLabel', [0:5:30], 'XTick', [0:500:3000], 'YTickLabel', [y1:10:y2],'YTick', [0:10:y2-y1], 'FontSize', 25)
title('(b) Note-level Estimation (proposed)', 'FontSize', 30)
colorbar

