function onsetFrame = onsetTime2frame(time, basicParameter)
    
    sampleIndex = time * basicParameter.sr;
    if sampleIndex < basicParameter.window
        onsetFrame = 1;
    else
        onsetFrame = ceil( ( sampleIndex - basicParameter.window )/ basicParameter.nfft) + basicParameter.onsetFine;
    end


    if onsetFrame < 1
        onsetFrame = 1;
    end
end