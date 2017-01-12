function X = audio2spectrogram(audioFilename, basicParameter)

d1 = audioread(audioFilename);
d1 = (d1(:,1) + d1(:,2))/2;

window = basicParameter.window;
noverlap = window - basicParameter.nfft;

s = spectrogram (d1, window, noverlap);

X = abs(s);
X(X==0) = eps;


if strcmp(basicParameter.scale, 'midi')
X = basicParameter.map_mx * X;
end

end