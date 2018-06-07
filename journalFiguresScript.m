%% Mazurka Project d
[resultData.title, idx] = sortrows(resultData.title);
resultData.compareRefVel = resultData.compareRefVel(1,idx);
resultData.error = resultData.error(:,idx);

%
error = zeros(4, length(resultData.title));
omittedNotesNum = zeros(2, length(resultData.title));
basicParameter.pedalThreshold = 20;

for i = 1:length(resultData.title)
    midiname = strcat(resultData.title{i}, '.mid');
    txtname = strcat(resultData.title{i}, '.mid_soft.csv');
    refVelCompare = resultData.compareRefVel{i};
    
    [error(:,i), omittedNotesNum(1,i), omittedNotesNum(2,i)] = calErrorExceptSoft(refVelCompare, midiname, txtname, basicParameter);
    
end

%


barGraph = bar([resultData.error(1,omittedNotesNum(2,:)>0.1)', error(1,omittedNotesNum(2,:)>0.1)', error(3,omittedNotesNum(2,:)>0.1)' ]);

ylabel('Absolute Error', 'FontSize', 20)
set(gca, 'XTickLabel', {'Chopin 10-3', 'Chopin 26-2', 'Chopin 28-17', 'Chopin 29', 'Chopin 48', 'Liszt Dante', 'Liszt S178', 'Rach. 36-1', 'Rach. 36-2'})
barGraph(1).FaceColor = 'k';
barGraph(2).FaceColor = 'w';


%% Soft pedal velocity truth-estimated comparison

targetPieceId = 31;
filename = resultData.title{targetPieceId};
midiname = strcat(filename, '.mid');
csvname = strcat(filename, '.mid_soft.csv');

midiMat = readmidi_java(midiname);
pedalMat = readPedalCsv(csvname);   

basicParameter.pedalThreshold = 100;


[woPedal, wPedal] = separateSoftPedal(midiMat, pedalMat, basicParameter.pedalThreshold, resultData.compareRefVel{1,targetPieceId}(:,3));

subplot(2,1,1)
hold off
scatter(woPedal(:,5)+rand(size(woPedal,1),1), woPedal(:,8)+rand(size(woPedal,1),1), 'filled', 'd', 'MarkerFaceColor', [0 0 0])
hold on
scatter(wPedal(:,5)+rand(size(wPedal,1),1), wPedal(:,8)+rand(size(wPedal,1),1), 'filled', 'MarkerFaceColor', [0.7 0.2 0.2])
plot([0:1:110], [0:1:110])

xlabel('Ground Truth MIDI Velocity', 'FontSize', 30)
ylabel('Estimated MIDI Velocity', 'FontSize', 30)
set(gca, 'FontSize', 25)
ylim([0 110])
xlim([0 110])
legend({'Notes without Soft Pedal', 'Notes with Soft Pedal'}, 'Location', 'best')
title('(a) Chopin op. 29') 


subplot(2,1,2)
targetPieceId = 21;
filename = resultData.title{targetPieceId};
midiname = strcat(filename, '.mid');
csvname = strcat(filename, '.mid_soft.csv');

midiMat = readmidi_java(midiname);
pedalMat = readPedalCsv(csvname);   

basicParameter.pedalThreshold = 100;


[woPedal, wPedal] = separateSoftPedal(midiMat, pedalMat, basicParameter.pedalThreshold, resultData.compareRefVel{1,targetPieceId}(:,3));
hold off
scatter(woPedal(:,5)+rand(size(woPedal,1),1), woPedal(:,8)+rand(size(woPedal,1),1), 'filled', 'd', 'MarkerFaceColor', [0 0 0])
hold on
scatter(wPedal(:,5)+rand(size(wPedal,1),1), wPedal(:,8)+rand(size(wPedal,1),1), 'filled', 'MarkerFaceColor', [0.7 0.2 0.2])
plot([0:1:110], [0:1:110])

xlabel('Ground Truth MIDI Velocity', 'FontSize', 30)
ylabel('Estimated MIDI Velocity', 'FontSize', 30)
set(gca, 'FontSize', 25)
ylim([0 110])
xlim([0 110])
legend({'Notes without Soft Pedal', 'Notes with Soft Pedal'}, 'Location', 'best')
title('(b) Chopin op. 10-3') 

% mean(abs(woPedal(:,5) - woPedal(:,8)))
% mean(abs(wPedal(:,5) - wPedal(:,8)))




%% mazurka Example script

midiname = 'op17no4.mid';
wavname = 'op17no4.wav';

midiMat = readmidi_java(midiname);
midiMat(:,7) = midiMat(:,7) + midiMat(:,6);

velMat = readmidi_java('op17no4_vel.mid');
velMat(:,7) = velMat(:,7) + velMat(:,6);

X = audio2spectrogram(wavname, basicParameter);
%
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



%%

fig1 = figure(1);
set(fig1, 'PaperUnits', 'points', 'PaperPosition', [0 0 1200 800])


hold off

xdata = velocityGainMatchingCell{1,1}{1,1};
ydata = velocityGainMatchingCell{1,1}{1,2};

pitch = 42;

% scatter(xdata(:,pitch)+rand(size(xdata(:,pitch))), log(ydata(:,pitch)), 40, [0 0.6 0], 'o', 'filled')
scatter(xdata(:,pitch)+rand(size(xdata(:,pitch))), ydata(:,pitch).^(1/10), 40, [0 0.6 0], 'o', 'filled')

hold on;

xdata = velocityGainMatchingCell{4,1}{1,1};
ydata = velocityGainMatchingCell{4,1}{1,2};

% scatter(xdata(:,pitch), log(ydata(:,pitch)), 40, [0.5 0 0], 's', 'filled')


xdata = velocityGainMatchingCell{1,1}{1,1};
ydata = velocityGainMatchingCell{1,1}{1,2};

pitch = pitch-12;

% scatter(xdata(:,pitch), log(ydata(:,pitch)), 40, [0 0 0.8], 'd', 'filled')
%%

xlabel('MIDI Velocity', 'FontName', 'Arial', 'FontSize', 40)

ylabel('Estimated Note Intensity (log)', 'FontName', 'Arial', 'FontSize', 40)
ylim([3 9])
set(gca, 'FontSize', 30)
[h,icons,plots,legend_text] = legend({'C4 notes in subset A', 'C4 notes in subset B', 'C3 notes in subset A'}, 'Location', 'Best', 'FontSize', 25);





for k = length(icons)/2+1 : length(icons)
icons(k).Children.MarkerSize = 15;
end

% print('fig1','-dpng','-r0')

