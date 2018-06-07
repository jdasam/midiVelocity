[resultData.title, idx] = sortrows(resultData.title);
resultData.compareRefVel = resultData.compareRefVel(1,idx);
resultData.error = resultData.error(:,idx);



%%
error = zeros(4, length(resultData.title));
omittedNotesNum = zeros(2, length(resultData.title));
basicParameter.pedalThreshold = 20;

for i = 1:length(resultData.title)
    midiname = strcat(resultData.title{i}, '.mid');
    txtname = strcat(resultData.title{i}, '.mid_soft.csv');
    refVelCompare = resultData.compareRefVel{i};
    
    [error(:,i), omittedNotesNum(1,i), omittedNotesNum(2,i)] = calErrorExceptSoft(refVelCompare, midiname, txtname, basicParameter);
    
end

%%


barGraph = bar([resultData.error(1,omittedNotesNum(2,:)>0.1)', error(1,omittedNotesNum(2,:)>0.1)', error(3,omittedNotesNum(2,:)>0.1)' ]);

ylabel('Absolute Error', 'FontSize', 20)
set(gca, 'XTickLabel', {'Chopin 10-3', 'Chopin 26-2', 'Chopin 28-17', 'Chopin 29', 'Chopin 48', 'Liszt Dante', 'Liszt S178', 'Rach. 36-1', 'Rach. 36-2'})
barGraph(1).FaceColor = 'k';
barGraph(2).FaceColor = 'w';


%%
targetPieceId = 37;
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
plot([0:1:110], [0:1:110])
scatter(wPedal(:,5)+rand(size(wPedal,1),1), wPedal(:,8)+rand(size(wPedal,1),1), 'filled', 'MarkerFaceColor', [0.7 0.2 0.2])

mean(abs(woPedal(:,5) - woPedal(:,8)))
mean(abs(wPedal(:,5) - wPedal(:,8)))