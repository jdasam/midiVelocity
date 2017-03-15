% plot W, H, updated H
timeStart = 80;
timeEnd = 200;
frequencyStart = 1;
frequencyEnd = 300; 
xTicSec = [0:0.5 :(timeEnd-timeStart) * 1024/44100];
xScaleBin = xTicSec * 44100 / 1024;
yTicFreq = [0 : 500 : frequencyEnd * 44100/8192];
yScaleBin = yTicFreq / 44100 * 8192;


noteList = [];
sheetFigure =[];
Bfigure = [];
Gfigure = [];

Gcopy = G;
Bcopy = B;
sheetMatrixCopy = sheetMatrixMidi;
Binitial = initializeWwithHarmonicConstraint(basicParameter);
Binitial = betaNormC(Binitial, basicParameter.beta);

if basicParameter.rankMode == 2
    tempG = zeros(size(G));
    tempB = zeros(size(B));
    tempSheet = zeros(size(sheetMatrixMidi));
    
    for i = 2:size(G,1)
        if i<90
            tempB(:,(i-1)*2) = B(:,i);
            tempBinitial(:,(i-1)*2) = Binitial(:,i);
            tempG((i-1)*2,:) = G(i,:);
            tempSheet((i-1)*2,:) = sheetMatrixMidi(i,:);
        else
            tempB(:,(i-89)*2+1) = B(:,i);
            tempBinitial(:,(i-89)*2+1) = Binitial(:,i);
            tempG((i-89)*2+1,:) = G(i,:);
            tempSheet((i-89)*2+1,:) = sheetMatrixMidi(i,:);
        end
        
    end
    G = tempG;
    B = tempB;
    Binitial = tempBinitial;
    sheetMatrixMidi = tempSheet;
end



for i = 2:size(sheetMatrixMidi,1)    
    if sum(sheetMatrixMidi(i,timeStart:timeEnd))
        if basicParameter.rankMode == 1
            noteList(length(noteList)+1) = i+19;
        else
            noteList(length(noteList)+1) = floor(i/2) + 20;
        end
        sheetFigure(length(noteList),:) = sheetMatrixMidi(i,timeStart:timeEnd);
        Gfigure(length(noteList),:) = G(i,timeStart:timeEnd);
        Bfigure(:,length(noteList)) = B(:,i);
        BiniFigure(:,length(noteList)) = Binitial(:,i);
    end    
end

G = Gcopy;
B = Bcopy;
sheetMatrixMidi = sheetMatrixCopy;


%
close all


fig1 = figure(1);
set(fig1, 'PaperUnits', 'points', 'PaperPosition', [0 0 3000 600])

% subplot(2,1,1)
% imagesc((X(1:300, timeStart:timeEnd)).^(1/4))
% axis 'xy'
% colormap(flipud(gray))
colormap(flipud(gray))


subplot(1,4,1)
imagesc(BiniFigure(frequencyStart:frequencyEnd,:).^0.3)
set(gca,'XTick',[1:1:length(noteList)], 'XTickLabel',noteList, 'YTick',yScaleBin, 'YTickLabel',yTicFreq, 'FontSize', 20)
axis 'xy'
xlabel('Midi Pitch', 'FontSize', 35)
ylabel('Frequency [Hz]', 'FontSize', 35)
title('(a) Initialization of W', 'FontSize', 45, 'FontName', 'Arial')



subplot(1,4,2)
imagesc(sheetFigure)
set(gca,'YTick',[1:1:length(noteList)], 'YTickLabel',noteList,'XTick',xScaleBin,'XTickLabel',xTicSec, 'FontSize', 25)
axis 'xy'
xlabel('Time [sec]', 'FontSize', 35)
ylabel('Midi Pitch', 'FontSize', 35)
title('(b) Initialization of H', 'FontSize', 45)

subplot(1,4,3)
imagesc(Bfigure(frequencyStart:frequencyEnd,:).^0.3)
set(gca,'XTick',[1:1:length(noteList)], 'XTickLabel',noteList, 'YTick',yScaleBin, 'YTickLabel',yTicFreq,'FontSize', 20)
axis 'xy'
xlabel('Midi Pitch', 'FontSize', 35)
ylabel('Frequency [Hz]', 'FontSize', 35)
title('(c) NMF result of W', 'FontSize', 45)


subplot(1,4,4)
imagesc(Gfigure)
set(gca,'YTick',[1:1:length(noteList)], 'YTickLabel',noteList,'XTick',xScaleBin,'XTickLabel',xTicSec, 'FontSize', 25)
axis 'xy'
xlabel('Time [sec]', 'FontSize', 35)
ylabel('Midi Pitch', 'FontSize', 35)
title('(d) NMF result of H', 'FontSize', 45)

print('fig1','-dpng','-r0')


%%
targetPitch = 25;
frequencyEnd = 150;
seeAttack = false;
numberOfPlot = 4;
yAxisLim = [0,0.12];


if seeAttack
    targetPitch = targetPitch + 88;
end


fig1 = figure(1);
set(fig1, 'PaperUnits', 'points', 'PaperPosition', [0 0 3000 3000])


yTicFreq = [0 : 200 : frequencyEnd * 44100/8192];
yScaleBin = yTicFreq / 44100 * 8192;

xTic = [0: 0.03 : 0.12];

% subplot(numberOfPlot,1,1)
% plot((targetB(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 2);
% hold on
% plot((targetB(1:frequencyEnd, targetPitch+88)), '--', 'LineWidth', 1.5);
% %plot((BBd(1:frequencyEnd, targetPitch)), ':','LineWidth', 2, 'Color', 'k');
% hold off
% set(gca,'XTick',yScaleBin ,'XTickLabel',yTicFreq ,'FontSize',15 ,'FontName','Times')
% 
% ylim(yAxisLim)
% ylabel('Normalized Intensity', 'FontSize', 20, 'FontName', 'Times');
% title('(a) Spectral Basis Learned from the Training Set', 'FontSize', 30, 'FontName', 'Times')

subplot(numberOfPlot,1,1)
targetB = BBdR2GfHc;
plot((targetB(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 3, 'Color', 'k');
hold on
plot((targetB(1:frequencyEnd, targetPitch+88)), '--', 'LineWidth', 3, 'Color', 'k');
hold off
set(gca,'XTick',yScaleBin ,'XTickLabel',yTicFreq,'YTick', xTic, 'FontSize', 35 ,'FontName','Arial')

ylim(yAxisLim)
ylabel('Intensity', 'FontSize', 40, 'FontName', 'Arial');
title('Strategy (a)', 'FontSize', 52, 'FontName', 'Arial')
% legend({'Harmonic Basis', 'Percussive Basis'},'FontSize', 50, 'FontName', 'Arial')


subplot(numberOfPlot,1,2)
targetB = BR2GfHc;
plot((targetB(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 3, 'Color', 'k');
hold on
plot((targetB(1:frequencyEnd, targetPitch+88)), '--', 'LineWidth', 3, 'Color', 'k');
hold off
set(gca,'XTick',yScaleBin ,'XTickLabel',yTicFreq ,'YTick', xTic, 'FontSize',35 ,'FontName','Arial')

ylim(yAxisLim)
ylabel('Intensity', 'FontSize',  40, 'FontName', 'Arial');
title('Strategy (b)', 'FontSize', 52, 'FontName', 'Arial')
% legend({'Harmonic Basis', 'Percussive Basis'},'FontSize',  50, 'FontName', 'Arial')



subplot(numberOfPlot,1,3)
targetB = BBdR2GfHcUibId10;
plot((targetB(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 3, 'Color', 'k');
hold on
plot((targetB(1:frequencyEnd, targetPitch+88)), '--', 'LineWidth', 3, 'Color', 'k');
hold off
set(gca,'XTick',yScaleBin ,'XTickLabel',yTicFreq ,'YTick', xTic, 'FontSize',35 ,'FontName','Arial')

ylim(yAxisLim)
ylabel('Intensity', 'FontSize',  40, 'FontName', 'Arial');
title('Strategy (c)', 'FontSize', 52, 'FontName', 'Arial')
% legend({'Harmonic Basis', 'Percussive Basis'},'FontSize', 50, 'FontName', 'Arial')


subplot(numberOfPlot,1,4)
targetB = BR2GfHcUbn5;
plot((targetB(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 3, 'Color', 'k');
hold on
plot((targetB(1:frequencyEnd, targetPitch+88)), '--', 'LineWidth', 3, 'Color', 'k');
hold off
set(gca,'XTick',yScaleBin ,'XTickLabel',yTicFreq ,'YTick', xTic, 'FontSize',35 ,'FontName','Arial')

ylim(yAxisLim)
ylabel('Intensity', 'FontSize',  40, 'FontName', 'Arial');
title('Strategy (d)', 'FontSize', 52, 'FontName', 'Arial')
xlabel('Frequency [Hz]', 'FontSize', 40, 'FontName', 'Arial');
% legend({'Harmonic Basis', 'Percussive Basis'},'FontSize',  50, 'FontName', 'Arial')
% subplot(numberOfPlot,1,6)
% targetB = BR2HcRand;
% plot((targetB(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 2);
% hold on
% plot((targetB(1:frequencyEnd, targetPitch+88)), '--', 'LineWidth', 1.5);
% hold off
% set(gca,'XTick',yScaleBin ,'XTickLabel',yTicFreq ,'FontSize',15 ,'FontName','Times')
% 
% xlabel('Frequency [Hz]', 'FontSize', 30, 'FontName', 'Times');
% ylim(yAxisLim)
% ylabel('Normalized Intensity', 'FontSize', 20, 'FontName', 'Times');
% title('(f) Spectral Basis Learned from one of the Test Set (Haydn) with Harmonic Constrained Random Initial W ', 'FontSize', 30, 'FontName', 'Times')
% 



%plot((BBdR2GfHcUibId10(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 3);
%plot((BBdR2GfHcUibId10(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 3);

%plot((BBdHc(1:400, targetPitch)));
print('fig1','-dpng','-r0')


%%
targetPitch = 55;

scatter(xdata(:,targetPitch), log(ydata(:,targetPitch)), 'k', 'filled' )

[lassoAll, stats] = lasso(xdata(1:max(find(xdata(:,targetPitch))),targetPitch), log(ydata(1:max(find(xdata(:,targetPitch))),targetPitch)), 'CV', 5);
fittingArray = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];


x= [10 :110];
y = x * fittingArray(1) + fittingArray(2);
hold on
plot(x, y, 'color', 'k', 'LineWidth', 2.5)
hold off

set(gca, 'FontSize',35 ,'FontName','Arial')
ylabel('Intensity (log)', 'FontSize',  40, 'FontName', 'Arial');
% title('Strategy (d)', 'FontSize', 52, 'FontName', 'Arial')
xlabel('MIDI Velocity', 'FontSize', 40, 'FontName', 'Arial');
legend({'Note data', 'Mapping curve'}, 'FontSize', 40, 'FontName', 'Arial', 'Location','northwest' )


