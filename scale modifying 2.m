MIDIFilename = 'newScale12.mid';

nmat = readmidi_java(MIDIFilename,true);
newMidi = zeros(size(nmat,1)*2, 8);

%%

newMidi(:,2) = 0.8;
newMidi(:,3) = 1;
newMidi(:,7) = 0.8;
newMidi(:,8) = 1;


for i = 0:length(newMidi)-1
    
    newMidi(i+1,1) = i;
    newMidi(i+1,4) = floor(i/24) + 21;
    newMidi(i+1,5) = mod(i,24) * 5 + 5;
    newMidi(i+1,6) = i * 1;
    
end

%%

writemidi_seconds(newMidi,'newScale24.mid');
