basicParameter = basicParameterInitialize();
basicParameter.spectrumMode = 1;
basicParameter.nfft= 512;
basicParameter.rankMode = 2;
basicParameter.alpha = 0;
basicParameter.attackLengthFrame = 10;
%%basicParameter.spectrumMode = 2;
%basicParameter.updateBnumber = 50;
filename = 'harmonicExampleVer3';
MIDIFilename = strcat(filename,'.mid');
MP3Filename =  strcat(filename, '.mp3');

Brandom = initializeWwithHarmonicConstraint(basicParameter);
Gx = velocityExtractionOption(MP3Filename, MIDIFilename, BR2GfHc, basicParameter);


basicParameter.spectrumMode = 2;
GxS2 = velocityExtractionOption(MP3Filename, MIDIFilename, BR2GfHc, basicParameter);


%%
basicParameter.alpha = 1000;
GxA = velocityExtractionOption(MP3Filename, MIDIFilename, BR2GfHc, basicParameter);
%
timeStart = 100;
timeEnd = 500;
xTicSec = [0:3 :(timeEnd-timeStart) * 512/44100];
xScaleBin = xTicSec * 44100 / 512;
%
fig1 = figure(1);
set(fig1, 'OuterPosition', [300, 800, 1800, 900])

%subplot(2,1,1)
plot(Gx(41,timeStart:timeEnd),'-' , 'LineWidth', 2)
hold on
plot(GxA(41,timeStart:timeEnd), ':', 'LineWidth', 3)
plot(Gx(29,timeStart:timeEnd), ':', 'LineWidth', 3)
plot(GxA(29,timeStart:timeEnd), ':', 'LineWidth', 3)

%plot(Gx(29+88,:))
%ylim([400 600])
hold off


%%
timeStart = 1;
timeEnd = 1000;
xTicSec = [0: 2 :(timeEnd-timeStart) * basicParameter.nfft/44100];
xScaleBin = xTicSec * 44100 / basicParameter.nfft;

fig1 = figure(1);
set(fig1, 'PaperUnits', 'points', 'PaperPosition', [0 0 3000 3000])

subplot(2,1,1)
plot(Gx(29,timeStart:timeEnd),'-' , 'LineWidth', 2, 'Color', 'r')
hold on
plot(Gx(41,timeStart:timeEnd), '-', 'LineWidth', 2, 'Color', 'b')
%plot(Gx(29+88,:))

hold off
ylim([0 820])
legend({'Activation of harmonic basis of C3', 'Activation of harmonic basis of C4'}, 'FontSize', 40, 'FontName', 'Arial')
set(gca,'XTick',xScaleBin ,'XTickLabel',xTicSec ,'FontSize',40 ,'FontName','Arial')
ylabel('Intensity',  'FontSize',60 ,'FontName','Arial')
title('(a) Linear Spectrogram',  'FontSize',70 ,'FontName','Arial')
xlim([timeStart timeEnd])

%
subplot(2,1,2)
plot(GxS2(29,timeStart:timeEnd),'-' , 'LineWidth', 2, 'Color', 'r')
hold on
plot(GxS2(41,timeStart:timeEnd), '-', 'LineWidth', 2, 'Color', 'b')
%plot(Gx(29+88,:))

hold off
ylim([0 820])
legend({'Activation of harmonic basis of C3', 'Activation of harmonic basis of C4'}, 'FontSize', 40, 'FontName', 'Arial')
set(gca,'XTick',xScaleBin ,'XTickLabel',xTicSec ,'FontSize',40 ,'FontName','Arial')
ylabel('Intensity',  'FontSize',60 ,'FontName','Arial')
title('(b) Power Spectrogram',  'FontSize', 70 ,'FontName','Arial')

xlabel('Time [sec]', 'FontSize', 60 ,'FontName','Arial')
xlim([timeStart timeEnd])

print('fig1','-dpng','-r0')
