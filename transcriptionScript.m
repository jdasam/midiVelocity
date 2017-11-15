load('/Users/Da/Documents/MATLAB/midiVelocityGit/BdR2GfHc.mat')


histData = zeros(15,4);
for i = 1:15
    histData(i,1) = resultData.histogramData{1,i}.f.b1;
    histData(i,2) = resultData.histogramData{1,i}.f.c1;
    histData(i,3) = resultData.histogramData{1,i}.f2.b1;
    histData(i,4) = resultData.histogramData{1,i}.f2.c1;
    
end
[lassoAll, stats] = lasso(histData(:,1), histData(:,3), 'CV', 5);
basicParameter.dynMed = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];
[lassoAll, stats] = lasso(histData(:,2), histData(:,4), 'CV', 5);
basicParameter.dynRan = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];

%%
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
basicParameter = basicParameterInitialize();
basicParameter.transcription = true;
basicParameter.rankMode = 2;
basicParameter.alpha = 0.1;
basicParameter.harmBoundary = 1;
basicParameter.harmConstrain = true;
basicParameter.Gfixed = true;
basicParameter.iterationScale = 5;

autoVelExtractSystem(basicParameter, {pwd}, 'test') 
%%
dataSet = getFileListWithExtension(strcat('*.','mp3'));
for dataIndex = 1 : 1%length(dataSet)
    fileName = dataSet{dataIndex};
    velocityCSVname = strcat(fileName, '_vel.csv');

    if exist(velocityCSVname, 'file')
        continue
    end
    
    if strcmp(fileName, 'midi')
        continue
    end
    
    fileName = 'Lisiecki, Jan';
    audioFilename = strcat(fileName, '.mp3');
    MIDIFilename = strcat(fileName, '.mid');
    basicParameter.nfft = 1024;
    basicParameter.noverlap = basicParameter.window - basicParameter.nfft;
    basicParameter.searchRange = 0.5;
    % basicParameter.attackExceptRange = 14;
    basicParameter.attackLengthSecond = 0.4;
    basicParameter.attackExceptRange = 0.4;
    basicParameter.fExtSecond = 0.3;
    basicParameter.bExtSecond = 0.5;
    basicParameter.updateBnumber = 50;
    basicParameter.GpreUpdate = 5;

    basicParameter.targetMedian = 65;
    basicParameter.targetRange = 25;

    basicParameter.transcription = true;
    basicParameter.threshold = 5;
    basicParameter.rankMode = 2;
    basicParameter.alpha = 1;
    basicParameter.harmBoundary = 1;
    basicParameter.harmConstrain = true;
    basicParameter.Gfixed = true;
    basicParameter.iterationScale = 5;
    basicParameter.updateBnumber = 50;
    basicParameter.onsetFine = 0;

    saveName = strcat(fileName, '_AMT.mid');
    [Gx, midiVel] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter);
    csvwrite(velocityCSVname, midiVel(:,5)');
    writemidi_seconds(midiVel, saveName);
end

%%
t1 = 1;
t2 = 500;
p1 = 15;
p2 = 60;

subplot(3,1,1)
imagesc(G(p1:p2,t1:t2))
axis xy

subplot(3,1,2)
imagesc(Ghyb4(p1:p2,t1:t2))
axis xy

subplot(3,1,3)
imagesc(G2k(p1:p2,t1:t2))
axis xy
%%
figure(1)
subplot(4,1,1)
imagesc(Gsheet(p1:p2,t1:t2) + Gsheet(p1+88:p2+88,t1:t2) * 0.5) 
axis xy
subplot(4,1,2)
imagesc(Ghyb3(p1:p2,t1:t2))
% imagesc(X(1:200,t1:t2))
axis xy
subplot(4,1,3)
% imagesc((Grand(p1:p2,t1:t2)   ).^0.7)
imagesc((Grand(p1:p2,t1:t2) + Grand(p1+88:p2+88,t1:t2 ) * 0.5 ).^0.7)
axis xy
%
Gtemp = sheetMatrixMidi;
Gtemp(Gtemp==0) = -1;
Gtemp(Gtemp>0) = 0;
Gtemp(Gtemp==-1) = 1;
Gdiff = Grand .* Gtemp;

subplot(4,1,4)
imagesc( (Grand2(p1:p2,t1:t2 ) + Grand2(p1+88:p2+88,t1:t2)*0.5 ).^0.7 )
axis xy

%%
t1 = 1;
t2 = 200;
p1 = 20;
p2 = 60;

subNum = 8;

figure(1)
subplot(subNum,1,1)
imagesc(Gsheet(p1:p2,t1:t2)) 
axis xy
subplot(subNum,1,2)
imagesc(Grand(p1:p2,t1:t2))
axis xy
subplot(subNum,1,3)
imagesc(Ghyb(p1:p2,t1:t2))
axis xy
subplot(subNum,1,4)
imagesc(Ghyb2(p1:p2,t1:t2))
axis xy
subplot(subNum,1,5)
imagesc(Ghyb3(p1:p2,t1:t2))
axis xy

subplot(subNum,1,6)
imagesc( (Grand2(p1:p2,t1:t2 )))
axis xy

subplot(subNum,1,7)
imagesc( (Ghyb4(p1:p2,t1:t2 )))
axis xy

subplot(subNum,1,8)
imagesc( (X(10:120,t1:t2 )))
axis xy

%%
figure(2)
tpitch = 40;
h1 = 1;
h2 = 700;

plot(Bsheet(h1:h2,tpitch));
hold on
plot(Brand2(h1:h2,tpitch));
% plot(B(h1:h2,tpitch));

% plot(test(h1:h2,tpitch));
% plot(Bhyb(h1:h2,tpitch));
% plot(Bhyb3(h1:h2,tpitch));


hold off

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




