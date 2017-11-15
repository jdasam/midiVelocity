MIDIFilename = 'newScale12.mid';

nmat = readmidi_java(MIDIFilename,true);
newMidi = zeros(size(nmat,1)/12, 8);

%%

newMidi(:,2) = 0.5;
newMidi(:,3) = 1;
newMidi(:,7) = 0.5;
newMidi(:,8) = 1;


for i = 0:length(newMidi)-1
    
    newMidi(i+1,1) = i + 1;
    newMidi(i+1,4) = i + 21;
    newMidi(i+1,5) = 64;
    newMidi(i+1,6) = i * 1 + 1;
    
end

%%

writemidi_seconds(newMidi,'scaleOnce.mid');
