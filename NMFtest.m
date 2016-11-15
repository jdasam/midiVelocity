function [Vhat, H] = NMFtest(audioFilename, MIDIFilename, B, fittingArray, basicParameter)




[d2,sr] = audioread(audioFilename);
d2 = (d2(:,1) + d2(:,2))/2;


nfft = 2048;
window = 8192;
noverlap = window - basicParameter.hopSize;
[s2, f, t] = spectrogram (d2, window, noverlap);


% Rewrite MIDI with fixed times
midiRef = readmidi_java(MIDIFilename,true);
midiRef(:,7) = midiRef(:,6) + midiRef(:,7);


% midiPitch - 19 ( ref scale's first note is 21, and this is second coloumn of B)
sheetMatrixMidi = rand(basicParameter.maxNote-19, ceil(midiRef(length(midiRef), 7) * sr/basicParameter.hopSize));



for j = 1 :size(sheetMatrixMidi,2)
    if sum(sheetMatrixMidi(:,j)) == 0
        sheetMatrixMidi(1, j) = 1;
    end
end



imagesc(sheetMatrixMidi)

X = abs(s2);


%imagesc(log(X))
axis('xy')

if size(sheetMatrixMidi,2) < size(X,2)
    X(:, size(sheetMatrixMidi,2) + 1 : size(X,2) ) = [];
elseif size(sheetMatrixMidi,2) > size(X,2)
    dummyMatrix = ones(size(X,1), size(sheetMatrixMidi,2) - size(X,2)) * 0.00000001;
    X = horzcat(X,dummyMatrix);
end

%X(501:4097,:) = ones(3597, size(X,2)) * 0.00000000001;



% Calculate Gx
Gx = sheetMatrixMidi;


Bcopy = B;
Bcopy = betaNormC(Bcopy,basicParameter.beta);

%[B, Gx, cost] = beta_nmf_H(X, basicParameter.beta, 10, B, Gx);
%Xhat = Bcopy * Gx;  

Xhat = sqrt(Bcopy.^2 * Gx.^2);
%betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta)


test = Bcopy' * (Xhat .^(-1));


Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
%Gx = Gx .* ( Bcopy'.^2 * (X.^2 .* ((Xhat.^2) .^(basicParameter.beta-2) )) ./ (Bcopy.^2 * ((Xhat.^2) .^ (basicParameter.beta-1))));
Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))));

%Gx = Gx .* sqrt( ( Bcopy'.^2 * (X .* (Xhat .^((basicParameter.beta-2)*2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1)))) );




%Gx = Gx .* sqrt ( ( (Bcopy' .^0 * Xhat) ./ (Bcopy' * Xhat .^ 0) ) .* (Bcopy' * (X .* (Xhat .^ -1))));
%Gx = Gx .* sqrt ( (Bcopy'.^2 * (X .* (Xhat .^ -2))) ./ (Bcopy'.^2 * Xhat .^ 0));




Bcopy = betaNormC(Bcopy,basicParameter.beta);
%Bcopy = normc(Bcopy);
Bcopy(find(isnan(Bcopy)))=0;


Gx(find(isnan(Gx)))=0;
Xhat = sqrt(Bcopy.^2 * Gx.^2);
%Xhat = Bcopy * Gx;  
%betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta)


betaDivVector = zeros(50);

for i = 1:50

    %Bcopy = Bcopy .* ((X .* (Xhat .^(basicParameter.beta-2) ) * Gx') ./ ((Xhat .^ (basicParameter.beta-1)) * Gx'));
    Gx = Gx .* ( Bcopy' * (X .* (Xhat .^(basicParameter.beta-2) )) ./ (Bcopy' * (Xhat .^ (basicParameter.beta-1))  ));
    %Gx = Gx .* ( Bcopy'.^2 * (X.^2 .* (Xhat.^2 .^(basicParameter.beta-2) )) ./ (Bcopy.^2 * (Xhat.^2 .^ (basicParameter.beta-1))));
    %Gx = Gx .* sqrt ( (Bcopy'.^2 * (X .* (Xhat .^ -2))) ./ (Bcopy'.^2 * Xhat .^ 0));



    Gx(find(isnan(Gx)))=0;
    %Bcopy = betaNormC(Bcopy,basicParameter.beta);
    %Bcopy(find(isnan(Bcopy)))=0;
    
    Xhat = sqrt(Bcopy.^2 * Gx.^2);
    %Xhat = Bcopy * Gx;  
    %betaDivergence = betaDivergenceMatrix(X, Xhat, basicParameter.beta);
    %betaDivVector(i) = betaDivergence;
    

end

H = Gx;
Vhat = Xhat;




end