function [A U]= erbtHarmclusNMF(X, A, U, F,f,alen, basicParameter, uFixed)

    nbfreq=250;
    nbcomp=1;
    maxclus=6;
    totwidth=22;
    clusspace=totwidth/maxclus;
    cluswidth=clusspace*2;
    beta=basicParameter.beta;
    fs = 22050;
    
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
    
    if ~uFixed
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
            V(:,cpos(n)+1:cpos(n)+nclus(n))=Z(:,ppos(n)+1:ppos(n)+nharm(n))*weights; % each partial * weights => spectra of a cluster
            %(center frequency of each cluster / center frequency of the first cluster 
            B(cpos(n)+1:cpos(n)+nclus(n),:)=10.^(-6/20*log2(clusfreq(cpos(n)+1:cpos(n)+nclus(n))/clusfreq(cpos(n)+1)).'*(1:nbcomp)); 
            % U = V * B (of cluster)
            U(:,(0:nbcomp-1)*nbnotes+n)=V(:,cpos(n)+1:cpos(n)+nclus(n))*B(cpos(n)+1:cpos(n)+nclus(n),:);
        end
        U = horzcat(U,ones(F,1));
    end
    U(find(isnan(U)))=0;
    %%% Performing NMF updates %%%
    %A=ones(nbnotes*nbcomp,N);
    Y= (U.^basicParameter.spectrumMode * A.^basicParameter.spectrumMode) .^(1/basicParameter.spectrumMode);
    gconverged=0; dist=inf;
    while ~gconverged,
        gprevdist=dist;
        % Updating note weights
        lconverged=0;
        while ~lconverged,
            lprevdist=dist;
            tempA=vertcat(A(89,:),A(1:88,:));
            tempU=horzcat(U(:,89),U(:,1:88));
            tempA = updateGwithTempoPartial(tempA, X, tempU, Y, basicParameter);
            A = vertcat(tempA(2:89,:),tempA(1,:));
            %A=A.*(U.'*(X.*Y.^(beta-2)))./(U.'*(Y.^(beta-1)));
            A(find(isnan(A))) = 0;
            Y= (U.^basicParameter.spectrumMode * A.^basicParameter.spectrumMode) .^(1/basicParameter.spectrumMode);
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
            lconverged=(10*log10(lprevdist/dist) < 5e-5);
        end
      % Updating note spectra
        lconverged=0;
        if ~uFixed
            while ~lconverged,
                lprevdist=dist;
                XYA=(X.*Y.^(beta-2))*A.';
                YA=(Y.^(beta-1))*A.';
                for n=1:nbnotes
                    % B .* ( V' * XYA ) ./ (V' * YA +realmin)    // cluster by cluster
                    B(cpos(n)+1:cpos(n)+nclus(n),:)=B(cpos(n)+1:cpos(n)+nclus(n),:).*(V(:,cpos(n)+1:cpos(n)+nclus(n)).'*XYA(:,(0:nbcomp-1)*nbnotes+n))./(V(:,cpos(n)+1:cpos(n)+nclus(n)).'*YA(:,(0:nbcomp-1)*nbnotes+n,:)+realmin);
                    U(:,(0:nbcomp-1)*nbnotes+n)=V(:,cpos(n)+1:cpos(n)+nclus(n))*B(cpos(n)+1:cpos(n)+nclus(n),:);
                end
                U(find(isnan(U)))=0;
                Y= (U.^basicParameter.spectrumMode * A.^basicParameter.spectrumMode) .^(1/basicParameter.spectrumMode);
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
                lconverged=(10*log10(lprevdist/dist) < 5e-5);
            end   
        end
            % Convergence test
        gconverged=(10*log10(gprevdist/dist) < 1e-4);     
    end

    %%% Energy normalization %%%
    %A=A.*(sum(U.^2).^.5.'*ones(1,N));
    U=U./(ones(F,1)*sum(U.^2).^.5);
end