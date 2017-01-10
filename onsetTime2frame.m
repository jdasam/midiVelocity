function onsetFrame = onsetTime2frame(time, basicParameter)
    
    sampleIndex = time * basicParameter.sr;
    if sampleIndex < basicParameter.window/2
        onsetFrame = 1;
    else
        onsetFrame = ceil( ( sampleIndex - basicParameter.window /2 )/ basicParameter.nfft);
    end


end