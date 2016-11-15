scatter(drParameter(1,:)/20, velTruth(1,:), 50, 'filled', 'black')
hold on
lsline

%scatter(drParameter(2,:), velTruth(2,:), 200)

ylabel('\mu of MIDI Velocity', 'FontSize', 25)
xlabel('\mu of Note Intensity (log)', 'FontSize', 25)

hold off
%%
midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);

window = 8192;
sr = 44100;
% midiPitch - 19 ( ref scale's first note is 21, and this is second coloumn of B)
sheetMatrixMidi = zeros(basicParameter.maxNote-19, ceil(midiRef(length(midiRef), 7) * basicParameter.sr/basicParameter.hopSize));
sheetMatrixMidiRoll = zeros(basicParameter.maxNote-19, ceil(midiRef(length(midiRef), 7) * basicParameter.sr/basicParameter.hopSize));

for i = 1 : length(midiRef)
    notePitch = midiRef(i,4) - 19;
    sampleIndex = midiRef(i,6) * basicParameter.sr;
    if sampleIndex < window/2
        onset = 1;
    else
        onset = ceil( ( sampleIndex - window /2 )/ basicParameter.hopSize) + 1;
    end
    offset = ceil( midiRef(i,7) * sr / basicParameter.hopSize) + 1;
    sheetMatrixMidi(notePitch, onset:offset) = 1;
    
    if onset > 2
        sheetMatrixMidi(notePitch, onset-2:onset+2) = 30 *[0.3, 0.6, 1, 0.6, 0.3];
    else
        sheetMatrixMidi(notePitch, onset:onset+2) = 30 * [1, 0.6, 0.3];
    end
    
    sheetMatrixMidiRoll(notePitch, onset:offset) = 1;
    
end




for j = 1 :size(sheetMatrixMidi,2)
    if sum(sheetMatrixMidi(:,j)) == 0
        sheetMatrixMidi(1, j) = 1;
    end
end


temp = sheetMatrixMidi(1,:);
sheetMatrixMidi(1,:) = [];
sheetMatrixMidi(89,:) =temp;


%%

temp = Gx(1,:);
Gx(1,:) = [];
Gx(89,:) = temp;
%%

imagesc(Gx)
%axis([540 740 1 89], 'xy')
axis([2000 2200 1 89], 'xy')

colormap('jet')

set(gca,'FontSize',18)
xlabel('Time (frame)', 'FontSize',25)
ylabel('Pitch (key number)', 'FontSize', 25)
%%
scatter(midiAnalysis.int(:,1), resultData.error(1,:), 50, 'filled')

set(gca,'FontSize',20)
xlabel('Average Interval of Notes (ms)', 'FontSize',25)
ylabel('Absoulte Error', 'FontSize', 25)
%%


scatter(midiAnalysis.int(:,1), resultData.velTruth(2,:))


