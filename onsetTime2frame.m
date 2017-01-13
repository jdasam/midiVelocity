function onsetFrame = onsetTime2frame(time, basicParameter)
    
    sampleIndex = time * basicParameter.sr;
    if sampleIndex < basicParameter.window
        onsetFrame = 1;
    else
        onsetFrame = ceil( ( sampleIndex - basicParameter.window )/ basicParameter.nfft) + 1;
    end


end