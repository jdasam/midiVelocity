function [minNote, maxNote, nmat] = readScale(basicParameter)

% Rewrite MIDI with fixed times
nmat = readmidi_java(basicParameter.MIDIFilename,true);
nmat(:,7) = nmat(:,6) + nmat(:,7);
noteArray = unique(nmat(:,4));

minNote = min(noteArray);
maxNote = max(noteArray);