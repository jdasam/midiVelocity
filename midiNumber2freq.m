function freq = midiNumber2freq (midiNumber, refA)
    if nargin < 2
        refA = 440;
    end
    
    freq = 2^( (midiNumber -69)/12 ) * refA; 
end