function [X, f, alen] = audio2erbt(audioFile, basicParameter)

[x,fs]=audioread(audioFile);
x=resample(x,22050,fs).';


F = 250;
wlen = basicParameter.nfft;

[I,T]=size(x);
N=ceil(T/wlen);

%%% Computing ERBT coefficients and frequency scale %%%
X=zeros(F,N,I);
for i=1:I,
    [X(:,:,i),f]=erbtm(x(i,:),fs,F,wlen);
end
X=(sum(X.^2,3)+1e-18).^.5;
fmin=f(1); fmax=f(F);
emin=9.26*log(.00437*fmin+1); emax=9.26*log(.00437*fmax+1);
e=(0:F-1)*(emax-emin)/(F-1)+emin;
a=.5*(F-1)/(emax-emin)*9.26*.00437*fs*exp(-e/9.26)-.5;
alen=2*round(a)+1;
f=f/fs;

end