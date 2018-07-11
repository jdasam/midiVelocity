%% Pieces with many soft pedal
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



%% Velocity - intensity pairs

fig1 = figure(1);
set(fig1, 'PaperUnits', 'points', 'PaperPosition', [0 0 1200 800])


hold off

xdata = velocityGainMatchingCell{1,1}{1,1};
ydata = velocityGainMatchingCell{1,1}{1,2};

pitch = 42;

scatter(xdata(:,pitch)+rand(size(xdata(:,pitch))), log(ydata(:,pitch)), 40, [0 0.6 0], 'o', 'filled')
% scatter(xdata(:,pitch)+rand(size(xdata(:,pitch))), ydata(:,pitch).^(1/10), 40, [0 0.6 0], 'o', 'filled')

hold on;

xdata = velocityGainMatchingCell{4,1}{1,1};
ydata = velocityGainMatchingCell{4,1}{1,2};

scatter(xdata(:,pitch), log(ydata(:,pitch)), 40, [0.5 0 0], 's', 'filled')


xdata = velocityGainMatchingCell{1,1}{1,1};
ydata = velocityGainMatchingCell{1,1}{1,2};

pitch = pitch-12;

scatter(xdata(:,pitch), log(ydata(:,pitch)), 40, [0 0 0.8], 'd', 'filled')
%
xlabel('MIDI Velocity', 'FontName', 'Arial', 'FontSize', 40)

ylabel('Estimated Note Intensity (log)', 'FontName', 'Arial', 'FontSize', 40)
ylim([3 9])
set(gca, 'FontSize', 30)
[h,icons,plots,legend_text] = legend({'C4 notes in subset A', 'C4 notes in subset B', 'C3 notes in subset A'}, 'Location', 'Best', 'FontSize', 25);





for k = length(icons)/2+1 : length(icons)
icons(k).Children.MarkerSize = 15;
end

% print('fig1','-dpng','-r0')

%% Result Compare by model
resultList ={};
resultCodeList = {'HarmPerc', 'HarmPerc_scale', 'Multi', 'Multi_scale'};

for i = 1:length(resultCodeList)
    tempResult = strcat('resultData', resultCodeList{i});   
    eval(['resultList{i} = ', tempResult ';']);
    
end
resultAverage = [];

for i=1:length(resultList)
    
    resultAverage(i, 1) = mean(resultList{i}.error(5,:)*100);
    resultAverage(i, 2) = mean(resultList{i}.error(6,:)*100);
%     resultAverage(i, 3) = std(resultList{i}.error(5,:)*100);
%     resultAverage(i, 4) = std(resultList{i}.error(6,:)*100);

end

barGraph = bar(resultAverage(:,1:2));
barGraph(1).FaceColor = 'k';
barGraph(2).FaceColor = 'w';
barGraph(2).LineWidth = 2;

ylim([5 26])
xlim([0 length(resultCodeList)+1])
%hold on;
%h=errorbar(resultAverage(:,1:2),resultAverage(:,3:4),'c'); set(h,'linestyle','none')
% hold off

% set(gca, 'XTickLabel', resultCodeList, 'FontName', 'Arial', 'FontSize', 20)
set(gca, 'XTickLabel', {'Harm-perc', 'Harm-perc + scale', 'Multi', 'Multi + scale'}, 'FontName', 'Arial', 'FontSize', 20)
ylabel('Relative Error (%)', 'FontSize', 30)

legend({'Piecewise Average of Mean Error', 'Piecewise Average of Error STD'})

%% Error Analysis
errorAnalFig = figure(1);
labelfontsize = 30;
tickfontsize = 25;
legendfontsize = 20;

set(errorAnalFig, 'PaperUnits', 'points', 'PaperPosition', [0 0 1200 2500])
set(errorAnalFig,'defaultAxesColorOrder',[ [0 0 0]; [0.2 0.2 0.2]]);
% set(gca, 'FontSize', tickfontsize)
numberOfSub = 5;

subplot(numberOfSub,1,1)
targetFeatureIndex = 1;
endIndex= 15;   
hold off
yyaxis left
plot(totalError(:,targetFeatureIndex), 'LineWidth', 3, 'Color', 'black')
% ylabel('Velocity Error', 'FontSize',50)
ylim([0 16])
hold on
yyaxis right
% plot([64 64], [0, 25])
% plot(totalErrorPerf(:,15), 'LineWidth', 3)
plot(totalError(:,targetFeatureIndex+1) / max(totalError(:,targetFeatureIndex+1)) * max(totalError(1:endIndex,targetFeatureIndex)), '--', 'LineWidth', 2)
yticklabel = [0:0.05:0.2]*100;
ytick = yticklabel * sum(totalError(:,targetFeatureIndex+1)) /  max(totalError(:,targetFeatureIndex+1))  * max(totalError(1:endIndex,targetFeatureIndex))/100;
set(gca, 'YTickLabel', yticklabel, 'YTick', ytick, 'FontSize', tickfontsize)
% plot(totalErrorR2(:,targetFeatureIndex), 'LineWidth', 3)

xlim([0 endIndex])
xlabel('Number of Simultaneous Onsets', 'FontSize', labelfontsize)
ylabel('Ratio of Notes (%)', 'FontSize',labelfontsize)
legend({'Mean Velocity Error', 'Number of Notes'}, 'FontSize', legendfontsize, 'Location', 'best')

yyaxis left
ylabel('Velocity Error', 'FontSize',labelfontsize)
title('(a)')


subplot(numberOfSub,1,2)
targetFeatureIndex = 3;
endIndex= 15;   
hold off
yyaxis left
plot(totalError(:,targetFeatureIndex), 'LineWidth', 3, 'Color', 'black')
% ylabel('Velocity Error', 'FontSize',50)
ylim([0 10])
hold on
yyaxis right
% plot([64 64], [0, 25])
% plot(totalErrorPerf(:,15), 'LineWidth', 3)
plot(totalError(:,targetFeatureIndex+1) / max(totalError(:,targetFeatureIndex+1)) * max(totalError(1:endIndex,targetFeatureIndex)), '--', 'LineWidth', 2)
yticklabel = [0:0.05:0.2]*100;
ytick = yticklabel * sum(totalError(:,targetFeatureIndex+1)) /  max(totalError(:,targetFeatureIndex+1))  * max(totalError(1:endIndex,targetFeatureIndex))/100;
set(gca, 'YTickLabel', yticklabel, 'YTick', ytick, 'FontSize', tickfontsize)
% plot(totalErrorR2(:,targetFeatureIndex), 'LineWidth', 3)

xlim([0 endIndex])
xlabel('Number of Sustained Notes', 'FontSize', labelfontsize)
ylabel('Ratio of Notes (%)', 'FontSize',labelfontsize)
legend({'Mean Velocity Error', 'Number of Notes'}, 'FontSize', legendfontsize, 'Location', 'best')

yyaxis left
ylabel('Velocity Error', 'FontSize',labelfontsize)
title('(b)')

subplot(numberOfSub,1,3)
targetFeatureIndex = 5;
endIndex= 127;
hold off
yyaxis left
plot(totalError(:,targetFeatureIndex), 'LineWidth', 3)
ylim([0 40]) 
hold on
% plot([64 64], [0, 25])
% plot(totalErrorPerf(:,15), 'LineWidth', 3)
yyaxis right
plot(totalError(:,targetFeatureIndex+1) / max(totalError(:,targetFeatureIndex+1)) *35, '--', 'LineWidth', 2)
% plot(totalErrorR2(:,targetFeatureIndex), 'LineWidth', 3)
yticklabel = [0:0.005:0.03]*100;
ytick = yticklabel * sum(totalError(:,targetFeatureIndex+1)) /  max(totalError(:,targetFeatureIndex+1))  * 35/ 100;
set(gca, 'YTickLabel', yticklabel, 'YTick', ytick, 'FontSize', tickfontsize)
xlim([0 endIndex])
% ylim([0 40]) 
xlabel('MIDI Velocity of Notes', 'FontSize',labelfontsize)
ylabel('Ratio of Notes (%)', 'FontSize',labelfontsize)
legend({'Mean Velocity Error', 'Number of Notes'}, 'FontSize', legendfontsize, 'Location', 'best')
yyaxis left
ylabel('Velocity Error', 'FontSize', labelfontsize)
title('(b)')


subplot(numberOfSub,1,4)
targetFeatureIndex = 7;
endIndex= 127;
hold off
yyaxis left
plot(totalError(:,targetFeatureIndex), 'LineWidth', 3)
hold on
yyaxis right
plot(totalError(:,targetFeatureIndex+1) / max(totalError(:,targetFeatureIndex+1)) * max(totalError(1:endIndex,targetFeatureIndex)), '--', 'LineWidth', 2)
% plot(totalErrorR2(:,targetFeatureIndex), 'LineWidth', 3)
yticklabel = [0:0.01:0.04]*100;
ytick = yticklabel * sum(totalError(:,targetFeatureIndex+1)) /  max(totalError(:,targetFeatureIndex+1))  * max(totalError(1:endIndex,targetFeatureIndex))/ 100;
set(gca, 'YTickLabel', yticklabel, 'YTick', ytick, 'FontSize', tickfontsize)
xlim([21 108])
xlabel('MIDI Pitch of Notes', 'FontSize',labelfontsize)
ylabel('Ratio of Notes (%)', 'FontSize',labelfontsize)
legend({'Mean Velocity Error', 'Number of Notes'}, 'FontSize', legendfontsize, 'Location', 'best')
yyaxis left
ylabel('Velocity Error', 'FontSize', labelfontsize)
title('(d)')


subplot(numberOfSub,1,5)
targetFeatureIndex = 13;
endIndex= 127;
hold off
yyaxis left
plot(totalError(:,targetFeatureIndex), 'LineWidth', 3)
ylabel('Velocity Error', 'FontSize', labelfontsize)
ylim([0 11])
hold on
yyaxis right
plot(totalError(:,targetFeatureIndex+1) / max(totalError(:,targetFeatureIndex+1)) * max(totalError(1:endIndex,targetFeatureIndex)), '--', 'LineWidth', 2)
% plot(totalErrorR2(:,targetFeatureIndex), 'LineWidth', 3)
yticklabel = [0:0.005:0.015]*100;
ytick = yticklabel * sum(totalError(:,targetFeatureIndex+1)) /  max(totalError(:,targetFeatureIndex+1))  * max(totalError(1:endIndex,targetFeatureIndex))/ 100;
set(gca, 'YTickLabel', yticklabel, 'YTick', ytick, 'FontSize', tickfontsize)
xlim([0 50])
xlabel('Number of Apperance of the Pitch in a Piece', 'FontSize',labelfontsize)
ylabel('Ratio of Notes (%)', 'FontSize',labelfontsize)
legend({'Mean Velocity Error', 'Number of Notes'}, 'FontSize', legendfontsize, 'Location', 'best')
title('(e)')


% print('errorAnalFig','-dpng','-r0')


%% Error by Align Error

alignErrorFig = figure(1);
labelfontsize = 30;
tickfontsize = 25;
legendfontsize = 20;

set(alignErrorFig, 'PaperUnits', 'points', 'PaperPosition', [0 0 1200 700])
set(alignErrorFig,'defaultAxesColorOrder',[ [0 0 0]; [0.2 0.2 0.2]]);
% subplot(2,1,1)
hold off
yyaxis left
plot(totalErrorDiff(:,15), 'LineWidth', 3)
hold on
% plot([64 64], [0, 25])
% plot(totalErrorPerf(:,15), 'LineWidth', 3)
yyaxis right
plot(totalErrorDiff(:,16) / max(totalErrorDiff(:,16)) * max(totalErrorDiff(:,15)), '--', 'LineWidth', 2)
% plot([0 127], [5, 5])


ratio = 100;
maximumValue = 63 * 1000 / ratio;
max100 = maximumValue - mod(maximumValue, 100);
xticklabel = [-max100:100:max100];
xtickposition = xticklabel / maximumValue/2 * 127 + 64;
yticklabel = [0:0.05:0.3]*100;
ytick = yticklabel * sum(totalError(:,targetFeatureIndex+1)) /  max(totalError(:,targetFeatureIndex+1))  * max(totalError(1:endIndex,targetFeatureIndex))/ 100;
set(gca, 'YTickLabel', yticklabel, 'YTick', ytick, 'FontSize', tickfontsize)
ylabel('Ratio of Notes (%)', 'FontSize',labelfontsize)

xlabel('Align Error (ms)', 'FontSize', labelfontsize)
yyaxis left
ylabel('Increas in Velocity Error', 'FontSize', labelfontsize)
set(gca, 'XTickLabel', xticklabel, 'XTick', xtickposition, 'FontSize', tickfontsize)
xlim([3 125])
title('Increase in Velocity Error When Using Semi-aligned MIDI', 'FontSize', labelfontsize+5)
ylim([0 35])
legend({'Mean Error Diff', 'Number of notes'})

%%
subplot(2,1,2)% Error by added and missed notes

hold off
plot(totalErrorDiffR2(:,17),'LineWidth', 2)
hold on
% plot(totalError(:,18) / max(totalError(:,18)) * max(totalError(:,17)))
plot(totalErrorDiffR2(:,19),'LineWidth', 2)
plot(totalErrorDiffR2(:,18) / max(totalErrorDiffR2(:,18)) * max(totalErrorDiffR2(:,17)), '--', 'LineWidth', 2)
% plot(totalErrorDiff(:,20) / max(totalErrorDiff(:,18)) * max(totalErrorDiff(:,17)), '--', 'LineWidth', 2)
plot(totalErrorDiff(:,17),'LineWidth', 2)
plot(totalErrorDiff(:,19),'LineWidth', 2)

% plot(totalErrorPerf(:,17),'LineWidth', 2)

% plot(totalErrorPerf(:,19),'LineWidth', 2)
xlim([1 9])
xlabel('Number of Extra or Mssing Notes', 'FontSize', 30)
ylabel('Velocity Error', 'FontSize', 30)
set(gca,'FontSize', 25)

legend({'Error by number of extra notes', 'Error by number of missing notes'} , 'FontSize', 20, 'Location', 'best')



% print('alignErrorFig','-dpng','-r0')


%% box plot mismatched notes

error_matched =  abs(totalNotesPerf(totalNotesPerf(:,12)==1, 3));
error_unmatched =  abs(totalNotesPerf(totalNotesPerf(:,12)==2, 3)); 
concatedX = [error_matched; error_unmatched];
g = [zeros(length(error_matched), 1); ones(length(error_unmatched), 1)];


% error_matrix = [ abs(totalNotesPerf(totalNotesPerf(:,12)==1, 3))   abs(totalNotesPerf(totalNotesPerf(:,12)==2, 3))   ];


boxplot(concatedX, g )
ylim([-0.5 31])

%% box plot 

targetFeature=4;

error_matched =  abs(totalNotesPerf(totalNotesPerf(:,12)==1, targetFeature));
error_unmatched =  abs(totalNotesPerf(totalNotesPerf(:,12)==2, targetFeature)); 
concatedX = [error_matched; error_unmatched];
g = [zeros(length(error_matched), 1); ones(length(error_unmatched), 1)];


% error_matrix = [ abs(totalNotesPerf(totalNotesPerf(:,12)==1, 3))   abs(totalNotesPerf(totalNotesPerf(:,12)==2, 3))   ];


boxplot(concatedX, g )
% ylim([-0.5 31])