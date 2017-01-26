% plot W, H, updated H
timeStart = 40;
timeEnd = 160;
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

if basicParameter.rankMode == 2
    tempG = zeros(size(G));
    tempB = zeros(size(B));
    tempSheet = zeros(size(sheetMatrixMidi));
    
    for i = 2:size(G,1)
        if i<90
            tempB(:,(i-1)*2) = B(:,i);
            tempG((i-1)*2,:) = G(i,:);
            tempSheet((i-1)*2,:) = sheetMatrixMidi(i,:);
        else
            tempB(:,(i-89)*2+1) = B(:,i);
            tempG((i-89)*2+1,:) = G(i,:);
            tempSheet((i-89)*2+1,:) = sheetMatrixMidi(i,:);
        end
        
    end
    G = tempG;
    B = tempB;
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
    end    
end

G = Gcopy;
B = Bcopy;
sheetMatrixMidi = sheetMatrixCopy;


%
close all


fig1 = figure(1);
set(fig1, 'OuterPosition', [300, 800, 1800, 400])

% subplot(2,1,1)
% imagesc((X(1:300, timeStart:timeEnd)).^(1/4))
% axis 'xy'
% colormap(flipud(gray))
colormap(flipud(gray))

subplot(1,3,1)
imagesc(Bfigure(frequencyStart:frequencyEnd,:))
set(gca,'XTick',[1:1:length(noteList)])
set(gca,'XTickLabel',noteList) 
set(gca,'YTick',yScaleBin)
set(gca,'YTickLabel',yTicFreq) 
axis 'xy'
xlabel('Midi Pitch', 'FontSize', 15)
title('Initialization of W', 'FontSize', 20)


subplot(1,3,2)
imagesc(sheetFigure)
set(gca,'YTick',[1:1:length(noteList)])
set(gca,'YTickLabel',noteList) 
set(gca,'XTick',xScaleBin) 
set(gca,'XTickLabel',xTicSec) 
axis 'xy'
xlabel('Time [sec]', 'FontSize', 15)
ylabel('Midi Pitch', 'FontSize', 15)
title('Initialization of H', 'FontSize', 20)


subplot(1,3,3)
imagesc(Gfigure)
set(gca,'YTick',[1:1:length(noteList)])
set(gca,'YTickLabel',noteList) 
set(gca,'XTick',xScaleBin) 
set(gca,'XTickLabel',xTicSec)
axis 'xy'
xlabel('Time [sec]', 'FontSize', 15)
ylabel('Midi Pitch', 'FontSize', 15)
title('NMF Result of H', 'FontSize', 20)


%%
targetPitch = 25;
frequencyEnd = 150;
seeAttack = false;
numberOfPlot = 4;
yAxisLim = [0,0.12];

targetB = BBdR2;


if seeAttack
    targetPitch = targetPitch + 88;
end


fig1 = figure(1);
set(fig1, 'OuterPosition', [300, 800, 1800, 2000])

yTicFreq = [0 : 200 : frequencyEnd * 44100/8192];
yScaleBin = yTicFreq / 44100 * 8192;

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
plot((targetB(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 2);
hold on
plot((targetB(1:frequencyEnd, targetPitch+88)), '--', 'LineWidth', 1.5);
hold off
set(gca,'XTick',yScaleBin ,'XTickLabel',yTicFreq ,'FontSize',15 ,'FontName','Times')

ylim(yAxisLim)
ylabel('Normalized Intensity', 'FontSize', 20, 'FontName', 'Times');
title('(a) Spectral Basis Learned from the Training Set with Harmonic Constraint', 'FontSize', 30, 'FontName', 'Times')
legend({'Harmonic Basis', 'Percussive Basis'},'FontSize', 30, 'FontName', 'Times')


subplot(numberOfPlot,1,2)
targetB = BR2GfHc;
plot((targetB(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 2);
hold on
plot((targetB(1:frequencyEnd, targetPitch+88)), '--', 'LineWidth', 1.5);
hold off
set(gca,'XTick',yScaleBin ,'XTickLabel',yTicFreq ,'FontSize',15 ,'FontName','Times')

ylim(yAxisLim)
ylabel('Normalized Intensity', 'FontSize', 20, 'FontName', 'Times');
title('(b) Spectral Basis Learned from the Synthesized Scale with Harmonic Constraint', 'FontSize', 30, 'FontName', 'Times')
legend({'Harmonic Basis', 'Percussive Basis'},'FontSize', 30, 'FontName', 'Times')



subplot(numberOfPlot,1,3)
targetB = BBdR2GfHcUibId10;
plot((targetB(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 2);
hold on
plot((targetB(1:frequencyEnd, targetPitch+88)), '--', 'LineWidth', 1.5);
hold off
set(gca,'XTick',yScaleBin ,'XTickLabel',yTicFreq ,'FontSize',15 ,'FontName','Times')

ylim(yAxisLim)
ylabel('Normalized Intensity', 'FontSize', 20, 'FontName', 'Times');
title('(c) Spectral Basis Learned from the Training Set based on Result (b)', 'FontSize', 30, 'FontName', 'Times')
legend({'Harmonic Basis', 'Percussive Basis'},'FontSize', 30, 'FontName', 'Times')


subplot(numberOfPlot,1,4)
targetB = BR2GfHcUbn5;
plot((targetB(1:frequencyEnd, targetPitch)), '-', 'LineWidth', 2);
hold on
plot((targetB(1:frequencyEnd, targetPitch+88)), '--', 'LineWidth', 1.5);
hold off
set(gca,'XTick',yScaleBin ,'XTickLabel',yTicFreq ,'FontSize',15 ,'FontName','Times')

ylim(yAxisLim)
ylabel('Normalized Intensity', 'FontSize', 20, 'FontName', 'Times');
title('(d) Spectral Basis Learned from one of the Test Set (Haydn) based on Result (b)', 'FontSize', 30, 'FontName', 'Times')
xlabel('Frequency [Hz]', 'FontSize', 30, 'FontName', 'Times');
legend({'Harmonic Basis', 'Percussive Basis'},'FontSize', 30, 'FontName', 'Times')

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




