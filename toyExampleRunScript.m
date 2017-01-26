basicParameter = basicParameterInitialize();
basicParameter.spectrumMode = 1;
basicParameter.nfft= 1024;
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

%
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
timeStart = 0;
timeEnd = 1600;
xTicSec = [0:3 :(timeEnd-timeStart) * 512/44100];
xScaleBin = xTicSec * 44100 / 512;

fig1 = figure(1);
set(fig1, 'OuterPosition', [300, 800, 1800, 900])

subplot(2,1,1)
plot(Gx(29,:),'-' , 'LineWidth', 2)
hold on
plot(Gx(41,:), ':', 'LineWidth', 3)
%plot(Gx(29+88,:))

hold off
ylim([0 800])
legend({'Activation of harmonic basis of C3', 'Activation of harmonic basis of C4'}, 'FontSize', 40, 'FontName', 'Times')
set(gca,'XTick',xScaleBin ,'XTickLabel',xTicSec ,'FontSize',30 ,'FontName','Times')
ylabel('Intensity',  'FontSize',40 ,'FontName','Times')
title('Linear Spectrogram',  'FontSize',40 ,'FontName','Times')

%
subplot(2,1,2)
plot(GxS2(29,:),'-' , 'LineWidth', 2)
hold on
plot(GxS2(41,:), ':', 'LineWidth', 3)
%plot(Gx(29+88,:))

hold off
ylim([0 800])
legend({'Activation of harmonic basis of C3', 'Activation of harmonic basis of C4'}, 'FontSize', 40, 'FontName', 'Times')
set(gca,'XTick',xScaleBin ,'XTickLabel',xTicSec ,'FontSize',30 ,'FontName','Times')
ylabel('Intensity',  'FontSize',40 ,'FontName','Times')
title('Power Spectrogram',  'FontSize',40 ,'FontName','Times')

xlabel('Time [seconds]', 'FontSize',40 ,'FontName','Times')
