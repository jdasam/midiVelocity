figure(3)

%%
subplot(1,2,2);
data1= getimage(figure(3));
subplot(1,2,1);
% data2= getimage(figure(3));
%%
f= figure(4);

frequencyLabel = [80,160, 320, 640, 1280, 2560, 5120]; % logspace(0,10,30); %[100:200:400 / basicParameter.window * basicParameter.sr];
[~, frequencyTick] = max(basicParameter.map_mx(:,round(frequencyLabel / basicParameter.sr * basicParameter.window)));
timeTickLabel = [0:0.2:1];
timeTick = (timeTickLabel) * basicParameter.sr / basicParameter.nfft;

range1=15;
range2=40;
range3=40;
c=[ones(range1,1), ones(range1,1), linspace(1,0,range1)';ones(range2,1), linspace(1,0,range2)', zeros(range2,1); linspace(1,0,range3)', zeros(range3,1), zeros(range3,1)  ];

subplot(1,2,1);
imagesc(data1/max(max(data1)))
set(gca, 'YTick', frequencyTick, 'YTickLabel', frequencyLabel, 'XTick', timeTick,'XTickLabel', timeTickLabel, 'FontName', 'Arial', 'FontSize', 25);
axis 'xy'
ylabel('Freqeuncy (Hz)', 'FontSize', 40, 'FontName', 'Arial')
title('(a) Note with Low Velocity',  'FontSize', 35, 'FontName', 'Arial')

subplot(1,2,2);
imagesc(data2/max(max(data2)))
axis 'xy'
set(gca, 'YTick', frequencyTick, 'YTickLabel', frequencyLabel, 'XTick', timeTick,'XTickLabel', timeTickLabel, 'FontName', 'Arial', 'FontSize', 25);
axis 'xy'
% ylabel('Freqeuncy (Hz)', 'FontSize', 30, 'FontName', 'Arial')
title('(b) Note with High Velocity',  'FontSize', 35, 'FontName', 'Arial')


colormap(c)



[ax,h1]=suplabel('Time (seconds)'); 
% [ax,h2]=suplabel('super Y label','y'); 
% [ax,h3]=suplabel('super Title' ,'t'); 
set(h1,'FontSize',40, 'FontName', 'Arial') 



%%

% c = [linspace(1,1,2)', linspace(1,1,2)', linspace(1,0,2)'; linspace(1,1,12)', linspace(1,0,12)', linspace(0,0,12)'; linspace(1,0,256)', linspace(0,0,256)', linspace(0,0,256)' ];
% c = flipud(hot);
% c = c.^10;
colormap(c)


%%
figure(4)
midiVelExample = midiVelCell{1,5};


histMIDI = histogram(midiVelExample(:,5), max(midiVelExample(:,5)) - min(midiVelExample(:,5)) + 1);

%%

