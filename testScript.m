fileName = 'Beethoven_Op027No1-02_003_20090916-SMD';
audioFilename = strcat(fileName, '.mp3');
MIDIFilename = strcat(fileName, '.mid');

basicParameter = basicParameterInitialize;
basicParameter.rankMode = 10;
basicParameter.updateBnumber = 50;
basicParameter.alpha2 = 1;
basicParameter.multiRankHopFrame = 2;

B = initializeWwithHarmonicConstraint(basicParameter);

[Gx, midiVel] = velocityExtractionOption(audioFilename, MIDIFilename, B, basicParameter);
