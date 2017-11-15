basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;

filename = 'Beethoven_Op027No1-02_003_20090916-SMD';
audioFilename = strcat(filename, '.mp3');
MIDIFilename = strcat(filename, '.mid');

%
Gx = velocityExtractionOption(audioFilename,MIDIFilename,BR2GfHcGpr5Ubn5,basicParameter);

%%
basicParameter.alpha = 100;
basicParameter.attackExceptRange = 9;
GxAlphaUbn = velocityExtractionOption(audioFilename,MIDIFilename,BR2GfHcGpr5Ubn5,basicParameter);
%%


%%

%case1
timeStart = 1680;
timeEnd = 1750;
basisStart = 1;
basisEnd = 72;
basis1 = 52;
basis2 = 40;

%case2
%%
timeStart = 1;
timeEnd = 500;
basisStart = 1;
basisEnd = 72;
basis1 = 25;
basis2 = 40;
plotSelect = 2;

subplot(2,1,1)
if plotSelect == 1
imagesc(Gx(basisStart:basisEnd, timeStart:timeEnd))
else
plot(Gx(basis1,timeStart:timeEnd));
hold on
plot(GxAlphaUbn(basis1,timeStart:timeEnd));
hold off
end

subplot(2,1,2)
if plotSelect==1
imagesc(GxAlphaUbn(basisStart:basisEnd, timeStart:timeEnd))
else
plot(Gx(basis2,timeStart:timeEnd));
hold on
plot(GxAlphaUbn(basis2,timeStart:timeEnd));
hold off
end
%%
plot(Gx(1:89,299))
hold on
plot(GxAlphaUbn(1:89,299))
hold off

%%
Gxtest = GxAlphaUbn - Gx;
Gxtest(Gxtest<0) = 0;
imagesc(Gxtest)
%plot(Gxtest(:,299))

%%
timeStart = 200;
timeEnd = 340;
basis1 = 25;
basisStart = 12;
basisEnd = 40;


noteList = [];
sheetFigure =[];
Bfigure = [];
Gfigure = [];

Gcopy = Gx;
GAcopy = GxAlphaUbn;

xTicSec = [5 : 0.5 : 7.5];
% xTicSec = [timeStart *  1024/44100 :0.5 : timeEnd* 1024/44100];
xScaleBin = (xTicSec - timeStart *  1024/44100 ) * 44100/1024;

% xScaleBin = [0:0.5 :(timeEnd-timeStart) * 1024/44100] * 44100 / 1024;

if basicParameter.rankMode == 2
    tempG = zeros(size(Gx));
    tempGA = zeros(size(GxAlphaUbn));
    
    for i = 2:size(Gx,1)
        if i<90
            tempG((i-1)*2,:) = Gx(i,:);
            tempGA((i-1)*2,:) = GxAlphaUbn(i,:);
        else
            tempG((i-89)*2+1,:) = Gx(i,:);
            tempGA((i-89)*2+1,:) = GxAlphaUbn(i,:);
        end
        
    end
    Gx = tempG;
    GxAlphaUbn = tempGA;
end



for i = 2:size(Gx,1)    
    if sum(Gx(i,timeStart:timeEnd))
        if basicParameter.rankMode == 1
            noteList(length(noteList)+1) = i+19;
        else
            noteList(length(noteList)+1) = floor(i/2) + 20;
        end
        Gfigure(length(noteList),:) = Gx(i,timeStart:timeEnd);
        GfigureA(length(noteList),:) = GxAlphaUbn(i,timeStart:timeEnd);
    end    
end

Gx = Gcopy;
GxAlphaUbn = GAcopy;

%%
colormap(flipud(gray))


subplot(3,1,1)
imagesc(Gfigure)
axis 'xy'
set(gca,'YTick',[1:2:length(noteList)]+0.5, 'YTickLabel',unique(noteList), 'XTick',xScaleBin ,'XTickLabel',xTicSec, 'FontName', 'Times', 'FontSize', 15)
xlim([0 140])
ylabel('Midi Pitch', 'FontSize', 30)
title('(a) H matrix without Temporal Cosntraint',  'FontSize', 30, 'FontName', 'Times')

%
subplot(3,1,2)
imagesc(GfigureA)
axis 'xy'
set(gca,'YTick',[1:2:length(noteList)]+0.5, 'YTickLabel',unique(noteList), 'XTick',xScaleBin ,'XTickLabel',xTicSec, 'FontName', 'Times', 'FontSize', 15)
ylabel('Midi Pitch', 'FontSize', 30)
title('(b) H matrix with Temporal Cosntraint',  'FontSize', 30)


subplot(3,1,3)
plot(Gx(basis1,timeStart:timeEnd), '--', 'LineWidth', 2);
hold on
plot(GxAlphaUbn(basis1,timeStart:timeEnd), 'LineWidth', 2);
hold off
set(gca, 'XTick',xScaleBin ,'XTickLabel',xTicSec,'FontName', 'Times', 'FontSize', 15)
xlim([0 140])
ylabel('Intensity', 'FontSize', 30)
title('(c) Intensity of harmonic basis of MIDI pitch 44',  'FontSize', 30)
xlabel('Time [sec]', 'FontSize', 40)
legend({'Intensity without Temporal Constraint', 'Intensity with Temporal Constraint'}, 'FontSize', 20, 'Location', 'northwest')