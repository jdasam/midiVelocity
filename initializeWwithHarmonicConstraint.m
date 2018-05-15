function W = initializeWwithHarmonicConstraint(basicParameter)

numberOfTotalKey = basicParameter.maxNote - basicParameter.minNote + 1;
sr = basicParameter.sr;
window = basicParameter.window;
referencePitch = basicParameter.referencePitch;
stretched = basicParameter.stretchedTuning;
% stretchedRatio = 1/12000;
stretchedRatio = 1/basicParameter.stretchedRatio;
f0stretchRatio = 1/basicParameter.f0stretchRatio;

% if basicParameter.rankMode == 1
%     W = zeros(basicParameter.window/2+1, numberOfTotalKey + 1);
% elseif basicParameter.rankMode == 2
%     W = zeros(basicParameter.window/2+1, numberOfTotalKey *2 + 1);
% end

W = zeros(basicParameter.window/2+1, numberOfTotalKey *basicParameter.rankMode + 1);
if basicParameter.frequencyThreshold < 1
    W(ceil(size(W,1)*basicParameter.frequencyThreshold):end,:) = [];
end

W(:,1) = rand(size(W,1),1);


if basicParameter.rankMode < 3

    for i = 2:numberOfTotalKey + 1

        f0 = midi2frequency(i+basicParameter.minNote-2, referencePitch, stretched, f0stretchRatio);
        f0low = midi2frequency(i+basicParameter.minNote-2 - basicParameter.harmBoundary, referencePitch,  stretched, f0stretchRatio);
        f0high = midi2frequency(i+basicParameter.minNote-2 + basicParameter.harmBoundary, referencePitch, stretched, f0stretchRatio);

        numberOfHarmonics = floor(basicParameter.sr/2/f0);

        for n = 1 : numberOfHarmonics
            if stretched
                nf0low = f0low * n* (1 + n^2 * stretchedRatio);
                nf0high = f0high * n* (1 + n^2* stretchedRatio);
            else
                nf0low = f0low * n;
                nf0high = f0high * n;
            end
            
            binLow = frequency2bin(nf0low, sr, window);
            binHigh = frequency2bin(nf0high, sr, window);

            if binHigh > size(W,1)
                binHigh = size(W,1);
            end

            W(binLow:binHigh, i) =1/n^2;

        end
    end

    if basicParameter.rankMode == 2
        %W(:,numberOfTotalKey + 2:end) = rand(size(W(:,numberOfTotalKey + 2:end)));
        W(:,numberOfTotalKey + 2:end) = ones(size(W(:,numberOfTotalKey + 2:end)));
    end

else
    for i = 1:numberOfTotalKey
        W(:, (i-1) * basicParameter.rankMode + 2) = 1;
        for j = 2:basicParameter.rankMode
            f0 = midi2frequency(i+basicParameter.minNote-1, referencePitch,stretched, f0stretchRatio);
            f0low = midi2frequency(i+basicParameter.minNote-1 - basicParameter.harmBoundary * (basicParameter.rankMode/ (basicParameter.rankMode + j )), referencePitch, stretched,f0stretchRatio );
            f0high = midi2frequency(i+basicParameter.minNote-1 + basicParameter.harmBoundary * (basicParameter.rankMode/ (basicParameter.rankMode + j )), referencePitch, stretched,f0stretchRatio);
            
            numberOfHarmonics = floor(basicParameter.sr/2/f0);
            for n = 1 : numberOfHarmonics
                if stretched
                    nf0low = f0low * n* (1 + n^2 * stretchedRatio);
                    nf0high = f0high * n* (1 + n^2* stretchedRatio);
                else
                    nf0low = f0low * n;
                    nf0high = f0high * n;
                end

                binLow = frequency2bin(nf0low, sr, window);
                binHigh = frequency2bin(nf0high, sr, window);
                    if binHigh > size(W,1)
                        binHigh = size(W,1);
                    end
                

                W(binLow:binHigh, (i-1) * basicParameter.rankMode + j + 1) =1/n^2;

            end
        end
%         harmonicPart = W(:, i * basicParameter.rankMode + 1);
%         harmonicPart(harmonicPart>0) = 1;
%         W(:, (i-1) * basicParameter.rankMode + 2) = W(:, (i-1) * basicParameter.rankMode + 2) - harmonicPart;
        
    end
    
    
end

end

function f = midi2frequency(p, middleApitch, stretched, f0stretchRatio])
    if stretched && p~=44
%         p = p + (p-44)^2 * (p-44)/abs(p-44) / 10000;
%         p = p + (p-44)^3  / 500000;
        p = p + (p-44)^3  / f0stretchRatio;
    end
      
    f = middleApitch * 2 ^ ((p - 69)/12);
end

function bin = frequency2bin(f, sr, window)
    bin = round( f / (sr/window) )+ 1;
end



