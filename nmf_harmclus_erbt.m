function [U,A,dist,B]=nmf_harmclus_erbt(x,fs,F,nbcomp,maxclus,clusspace,cluswidth,beta)

% NMF_HARMCLUS_ERBT Harmonic NMF of a signal from a ERB transform with
% basis spectra representing partial clusters and fundamental frequencies
% on the MIDI scale tuned at 440 Hz
%
% Initialization with a slope of 6 dB/octave for the first component, 12
% dB/oct for the second, etc
%
% [U,A,dist,B]=nmf_harmclus_erbt(x,fs,F,nbcomp,maxclus,clusspace,cluswidth,beta)
%
% Inputs:
% x: 1 x T vector containing a single-channel signal
% fs: sampling frequency in Hz
% F: number of frequency bins
% nbcomp: number of spectral envelope components per note
% maxclus: maximal number of partial clusters per note
% clusspace: spacing between successive partial clusters in ERB
% cluswidth: bandwidth of each partial cluster in ERB
% beta: distortion measure (0-> IS, 1-> KL, 2-> EUC)
%
% Output:
% U: F x (nbnotes x nbcomp) matrix containing NMF basis vectors
% A: (nbnotes x nbcomp) x N matrix containing NMF time weights
% dist: achieved distortion measure
% B: nbclus x nbcomp matrix containing spectral envelopes

%%% Errors and warnings %%%
if nargin<8, error('Not enough input arguments.'); end
[I,T]=size(x);
if I>T, error('The input signal must contain more time samples than channels.'); end
if fs>25000, error('The sampling frequency must be smaller than 25 kHz.'); end
wlen=2^nextpow2(.02*fs);    %20 ms window length
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

%%% Defining partial spectra %%%
firstnote=21; lastnote=108; nbnotes=lastnote-firstnote+1; pitch=firstnote:lastnote;
f0=2.^((pitch-69)/12)*440/fs;
nharm=floor(.5./f0);
ppos=[0,cumsum(nharm)];
nbpart=ppos(end);
Z=zeros(F,nbpart);   %partial spectra
partfreq=zeros(1,nbpart);
for n=1:nbnotes,
    partfreq(ppos(n)+1:ppos(n)+nharm(n))=f0(n)*(1:nharm(n));
end
for c=1:F,
    Z(c,:)=abs(sinc((f(c)-partfreq)*alen(c))+.5*sinc((f(c)-partfreq)*alen(c)+1)+.5*sinc((f(c)-partfreq)*alen(c)-1));
end

%%% Defining cluster spectra and initializing note spectra %%%
clusnum=zeros(1,nbpart);    % cluster index for each partial
for n=1:nbnotes,
    clusnum(ppos(n)+1:ppos(n)+nharm(n))=9.26*(log(.00437*partfreq(ppos(n)+1:ppos(n)+nharm(n))*fs+1)-log(.00437*partfreq(ppos(n)+1)*fs+1))/clusspace;
end
nclus=min(maxclus,round(clusnum(ppos(2:end)))+1);
cpos=[0,cumsum(nclus)];
nbclus=cpos(end);
clusfreq=zeros(1,nbclus);   % center frequency of each cluster
for n=1:nbnotes,
    clusfreq(cpos(n)+1:cpos(n)+nclus(n))=((.00437*partfreq(ppos(n)+1)*fs+1)*exp(clusspace/9.26*(0:nclus(n)-1))-1)/(.00437*fs);
end
V=zeros(F,nbclus);   %cluster spectra
B=zeros(nbclus,nbcomp);  %cluster weights
U=zeros(F,nbnotes*nbcomp);  %note spectra
for n=1:nbnotes,
    weights=zeros(nharm(n),nclus(n));
    for c=1:nclus(n),
        r=(clusnum(ppos(n)+1:ppos(n)+nharm(n))-c+1)*clusspace/cluswidth;
        order=4;
        k=sqrt(pi)*gamma(order-.5)/gamma(order);
        weights(:,c)=(1+(k*r).^2).^-order;
    end
    V(:,cpos(n)+1:cpos(n)+nclus(n))=Z(:,ppos(n)+1:ppos(n)+nharm(n))*weights;
    B(cpos(n)+1:cpos(n)+nclus(n),:)=10.^(-6/20*log2(clusfreq(cpos(n)+1:cpos(n)+nclus(n))/clusfreq(cpos(n)+1)).'*(1:nbcomp));
    U(:,(0:nbcomp-1)*nbnotes+n)=V(:,cpos(n)+1:cpos(n)+nclus(n))*B(cpos(n)+1:cpos(n)+nclus(n),:);
end

%%% Performing NMF updates %%%
A=ones(nbnotes*nbcomp,N);
Y=U*A;
gconverged=0; dist=inf;
while ~gconverged,
    gprevdist=dist;
    % Updating note weights
    lconverged=0;
    while ~lconverged,
        lprevdist=dist;
        A=A.*(U.'*(X.*Y.^(beta-2)))./(U.'*(Y.^(beta-1)));
        Y=U*A;
        switch beta
            case 0,
                dist=sum(sum(X./Y-log(X./Y)-1));
            case 1,
                dist=sum(sum(X.*log(X./Y)+Y-X));
            case 2,
                dist=.5*sum(sum((X-Y).^2));
            otherwise
                dist=sum(sum(X.^beta+(beta-1)*Y.^beta-beta*X.*Y.^(beta-1)))/(beta*(beta-1));
        end
        lconverged=(10*log10(lprevdist/dist) < 5e-3);
    end
    % Updating note spectra
    lconverged=0;
    while ~lconverged,
        lprevdist=dist;
        XYA=(X.*Y.^(beta-2))*A.';
        YA=(Y.^(beta-1))*A.';
        for n=1:nbnotes,
            B(cpos(n)+1:cpos(n)+nclus(n),:)=B(cpos(n)+1:cpos(n)+nclus(n),:).*(V(:,cpos(n)+1:cpos(n)+nclus(n)).'*XYA(:,(0:nbcomp-1)*nbnotes+n))./(V(:,cpos(n)+1:cpos(n)+nclus(n)).'*YA(:,(0:nbcomp-1)*nbnotes+n,:)+realmin);
            U(:,(0:nbcomp-1)*nbnotes+n)=V(:,cpos(n)+1:cpos(n)+nclus(n))*B(cpos(n)+1:cpos(n)+nclus(n),:);
        end
        Y=U*A;
        switch beta
            case 0,
                dist=sum(sum(X./Y-log(X./Y)-1));
            case 1,
                dist=sum(sum(X.*log(X./Y)+Y-X));
            case 2,
                dist=.5*sum(sum((X-Y).^2));
            otherwise
                dist=sum(sum(X.^beta+(beta-1)*Y.^beta-beta*X.*Y.^(beta-1)))/(beta*(beta-1));
        end
        lconverged=(10*log10(lprevdist/dist) < 5e-3);
    end
    % Convergence test
    gconverged=(10*log10(gprevdist/dist) < 1e-2);
end

%%% Energy normalization %%%
A=A.*(sum(U.^2).^.5.'*ones(1,N));
U=U./(ones(F,1)*sum(U.^2).^.5);

return;