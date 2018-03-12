
basicParameter.source = 'rand';
basicParameter.updateBnumber = 20;
basicParameter.softConstraint = false;
basicParameter.iterationData = 60;
basicParameter.postUpdate = true;
basicParameter.iterationPost = 30;
basicParameter.rankMode = 2;

B = initializeWwithHarmonicConstraint(basicParameter);

%%
filename = 'Bach_BWV849-01_001_20090916-SMD';
audioFilename = strcat(filename, '.mp3');
MIDIfilename = strcat(filename, '.mid');

[G,~,~,~,~,~,~,B] = velocityExtractionOption(audioFilename, MIDIfilename,B, basicParameter);
[B,G] =r2matrixToCommon(B,G);


%%
% G = GsoftR8;
% B = BsoftR8;


nmat = readmidi_java(MIDIfilename);
nmat(:,7) = nmat(:,6) + nmat(:,7);


tStart = 2;
tDur = 3.8;

t1 = floor(tStart * basicParameter.sr / basicParameter.nfft);
t2 = ceil((tStart+tDur)  * basicParameter.sr / basicParameter.nfft);

f1 = 1;
f2 = 300;



tempParam = basicParameter;
tempParam.rankMode= 1;
sheetMatrix = midi2MatrixOption(nmat, size(G,2), tempParam, false, false);
sheetMatrixClip = sheetMatrix(2:end, t1:t2);
constraintMat = midi2MatrixOption(nmat, size(G,2), basicParameter, false, false);
harmonicCons = initializeWwithHarmonicConstraint(basicParameter);
harmonicCons(harmonicCons>0) = 1;
pitchList = find(sum(sheetMatrixClip,2)>0);

Gvalid = zeros(length(pitchList) * basicParameter.rankMode, t2-t1+1);
Bvalid = zeros(f2-f1+1, length(pitchList) * basicParameter.rankMode);
Cvalid = zeros(size(Gvalid));
harmonicValid = zeros(size(Bvalid));

for i = 1:length(pitchList)
    Gvalid((i-1)*basicParameter.rankMode+1:i*basicParameter.rankMode,:) = G( (pitchList(i)-1) *basicParameter.rankMode+2:pitchList(i) *basicParameter.rankMode+1,t1:t2);
    Bvalid(:,(i-1)*basicParameter.rankMode+1:i*basicParameter.rankMode) = B(f1:f2,(pitchList(i)-1) *basicParameter.rankMode+2:pitchList(i) *basicParameter.rankMode+1);
    Cvalid((i-1)*basicParameter.rankMode+1:i*basicParameter.rankMode,:) = constraintMat( (pitchList(i)-1) *basicParameter.rankMode+2:pitchList(i) *basicParameter.rankMode +1  ,t1:t2);
    harmonicValid(:,(i-1)*basicParameter.rankMode+1:i*basicParameter.rankMode) = harmonicCons(f1:f2,(pitchList(i)-1) *basicParameter.rankMode+2:pitchList(i) *basicParameter.rankMode+1);
end

%%
frequencyLabel = [100:200:f2 / basicParameter.window * basicParameter.sr];
frequencyTick = frequencyLabel / basicParameter.sr * basicParameter.window;
basisTickLabel = pitchList + 20;
basisTick = [(2+1)/2 : 2: size(Gvalid,1)];
basisTick2 = [(5+1)/2 : 5: size(Gvalid,1)];
timeTickLabel = [tStart:0.5:tStart+tDur];
timeTick = (timeTickLabel-tStart) * basicParameter.sr / basicParameter.nfft;

%%


fig1 = figure(1);
set(fig1, 'PaperUnits', 'points', 'PaperPosition', [0 0 1000 1500])


whiteRedColormap = [ones(256,1), linspace(1,0,256)',linspace(1,0,256)'  ];

subplot(3,2,1);
colormap(flipud(gray))
imagesc(Bvalid0.^0.5)
freezeColors;

set(gca, 'YTick', frequencyTick, 'YTickLabel', frequencyLabel, 'XTick', basisTick,'XTickLabel', basisTickLabel, 'FontName', 'Arial', 'FontSize', 25);
axis 'xy'
ylabel('Freqeuncy (Hz)', 'FontSize', 30, 'FontName', 'Arial')
title('(a) W in Perc-Harm Model',  'FontSize', 30, 'FontName', 'Arial')


% freezeColors;
hold on
% harmImage = imagesc(harmonicValid);
% set(harmImage, 'AlphaData', 0.1);
hold off
% colormap(whiteRedColormap);


subplot(3,2,2);

imagesc(Gvalid0.^0.5)
colormap(flipud(gray))
freezeColors;


% freezeColors;
% hold on
% consImage = imagesc(Cvalid);
% set(consImage, 'AlphaData', 0.4);
% hold off
axis 'xy'
set(gca, 'YTick', basisTick, 'YTickLabel', basisTickLabel, 'XTick', timeTick ,'XTickLabel', timeTickLabel , 'FontName', 'Arial', 'FontSize', 25);
ylabel('MIDI Pitch', 'FontSize', 30, 'FontName', 'Arial')
title('(b) H in Perc-Harm Model ',  'FontSize', 30, 'FontName', 'Arial')

subplot(3,2,3);
imagesc(Bvalid1.^0.5)
freezeColors;

set(gca, 'YTick', frequencyTick, 'YTickLabel', frequencyLabel, 'XTick', basisTick2,'XTickLabel', basisTickLabel, 'FontName', 'Arial', 'FontSize', 25);
axis 'xy'
ylabel('Freqeuncy (Hz)', 'FontSize', 30, 'FontName', 'Arial')
title('(c) W in Multiple Basis Model',  'FontSize', 30, 'FontName', 'Arial')


subplot(3,2,4);
imagesc(Gvalid1.^0.5)
freezeColors;

axis 'xy'
set(gca, 'YTick', basisTick2, 'YTickLabel', basisTickLabel, 'XTick', timeTick ,'XTickLabel', timeTickLabel , 'FontName', 'Arial', 'FontSize', 25);
ylabel('MIDI Pitch', 'FontSize', 30, 'FontName', 'Arial')
title('(d) H in Multiple Basis Model',  'FontSize', 30, 'FontName', 'Arial')


subplot(3,2,5)
imagesc(Bvalid.^0.4)
xlabel('MIDI Pitch', 'FontSize', 30, 'FontName', 'Arial')
ylabel('Freqeuncy (Hz)', 'FontSize', 30, 'FontName', 'Arial')
set(gca, 'YTick', frequencyTick, 'YTickLabel', frequencyLabel, 'XTick', basisTick2,'XTickLabel', basisTickLabel, 'FontName', 'Arial', 'FontSize', 25);
axis 'xy'
title('(e) W with Soft Constraint',  'FontSize', 30, 'FontName', 'Arial')


freezeColors;
hold on
harmImage = imagesc(harmonicValid);
set(harmImage, 'AlphaData', 0.1);
hold off
% colormap(whiteRedColormap);

subplot(3,2,6)
imagesc(Gvalid.^0.3)
axis 'xy'
set(gca, 'YTick', basisTick2, 'YTickLabel', basisTickLabel, 'XTick', timeTick ,'XTickLabel', timeTickLabel , 'FontName', 'Arial', 'FontSize', 25);
ylabel('MIDI Pitch', 'FontSize', 30, 'FontName', 'Arial')
xlabel('Time (sec)', 'FontSize', 30, 'FontName', 'Arial')
title('(f) H with Soft Constraint',  'FontSize', 30, 'FontName', 'Arial')

freezeColors;
hold on
consImage = imagesc(Cvalid);
set(consImage, 'AlphaData', 0.4);
hold off


colormap(whiteRedColormap)

print('fig1','-dpng','-r0')

