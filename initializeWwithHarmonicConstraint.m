function W = initializeWwithHarmonicConstraint(basicParameter)

numberOfTotalKey = basicParameter.maxNote - basicParameter.minNote + 1;
sr = basicParameter.sr;
window = basicParameter.window;


% if basicParameter.rankMode == 1
%     W = zeros(basicParameter.window/2+1, numberOfTotalKey + 1);
% elseif basicParameter.rankMode == 2
%     W = zeros(basicParameter.window/2+1, numberOfTotalKey *2 + 1);
% end

W = zeros(basicParameter.window/2+1, numberOfTotalKey *basicParameter.rankMode + 1);


W(:,1) = rand(size(W,1),1);


if basicParameter.rankMode < 3

    for i = 2:numberOfTotalKey + 1

        f0 = midi2frequency(i+basicParameter.minNote-2);
        f0low = midi2frequency(i+basicParameter.minNote-2 - basicParameter.harmBoundary);
        f0high = midi2frequency(i+basicParameter.minNote-2 + basicParameter.harmBoundary);

        numberOfHarmonics = floor(basicParameter.sr/2/f0);

        for n = 1 : numberOfHarmonics
            binLow = frequency2bin(f0low * n, sr, window);
            binHigh = frequency2bin(f0high * n, sr, window);

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
            f0 = midi2frequency(i+basicParameter.minNote-1);
            f0low = midi2frequency(i+basicParameter.minNote-1 - basicParameter.harmBoundary * (basicParameter.rankMode/ (basicParameter.rankMode + j )));
            f0high = midi2frequency(i+basicParameter.minNote-1 + basicParameter.harmBoundary * (basicParameter.rankMode/ (basicParameter.rankMode + j )));
            
            numberOfHarmonics = floor(basicParameter.sr/2/f0);
            for n = 1 : numberOfHarmonics
                binLow = frequency2bin(f0low * n, sr, window);
                binHigh = frequency2bin(f0high * n, sr, window);

                if binHigh > size(W,1)
                    binHigh = size(W,1);
                end

                W(binLow:binHigh, (i-1) * basicParameter.rankMode + j + 1) =1/n^2;

            end
        end
        
        
        
    end
    
    
end

if basicParameter.softConstraint && basicParameter.beta2 ~= 0
    
%     W = rand(size(W));
end


end

function f = midi2frequency(p)
    f = 440 * 2 ^ ((p - 69)/12);
end

function bin = frequency2bin(f, sr, window)
    bin = round( f / (sr/window) )+ 1;
end

