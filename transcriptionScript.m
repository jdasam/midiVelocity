tp1 = 40;
tp1ind= max(find(xdata(:,tp1)));
scatter(xdata(1:tp1ind,tp1),log(ydata(1:tp1ind,tp1)),  'o')
hold on;
tp2 = 52;
tp2ind= max(find(xdata(:,tp2)));
scatter(xdata(1:tp1ind,tp2),log(ydata(1:tp1ind,tp2)),  'd')
tp3 = 64;
tp2ind= max(find(xdata(:,tp3)));
plot(xdata(1:tp1ind,tp3),log(ydata(1:tp1ind,tp3)),  '+')
tp4 = 28;
tp2ind= max(find(xdata(:,tp4)));
plot(xdata(1:tp1ind,tp4),log(ydata(1:tp1ind,tp4)),  'x')

hold off;
legend('MIDI Pitch 60', 'MIDI Pitch 72', 'MIDI Pitch 84', 'MIDI Pitch 28')

ylim([2 8])
xlabel('MIDI Velocity')
ylabel('Intensity (log')

%%



fileName = 'Horowitz, Vladimir';
audioFilename = strcat(fileName, '.mp3');
MIDIFilename = strcat(fileName, '.mid');
basicParameter.attackExceptRange = 7;
basicParameter.transcription = true;
basicParameter.updateBnumber = 50;
basicParameter.onsetFine = 3;
basicParameter.alpha = 0.01;
velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter)

%%
t1 = 50;
t2 = 120;
p1 = 40;
p2 = 60;

subplot(4,1,3)
imagesc(Grand(p1:p2,t1:t2))
subplot(4,1,2)
imagesc(Gsheet(p1:p2,t1:t2))
subplot(4,1,1)
imagesc(sheetMatrixMidi(p1:p2,t1:t2))
%
Gtemp = sheetMatrixMidi;
Gtemp(Gtemp==0) = -1;
Gtemp(Gtemp>0) = 0;
Gtemp(Gtemp==-1) = 1;
Gdiff = Grand .* Gtemp;

subplot(4,1,4)
imagesc(Gdiff(p1:p2,t1:t2))

%%
tp = 40;
f1 = 1;
f2 = 200;

% plot(B(f1:f2,tp+88))
% hold on
plot(log(uB(f1:f2,tp+88)))
hold on
plot(log(eB(f1:f2,tp+88)))
hold off

%%
test = G  [zeros(size(G,1),1) G(:,1:end-1)];
test(isnan(test))=0;




