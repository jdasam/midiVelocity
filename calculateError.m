function [error, errorPerNoteResult, refVelCompare, numberOfNotesByError] = calculateError(midiRef, midiVel, gainFromVelVec, gainCalculatedVec)

errorMatrix = zeros(length(midiVel),3);
numberOfNotesByError = zeros(127,1);

for i = 1: length(midiVel)
    errorMatrix(i,1) = midiRef(i,4);
    errorMatrix(i,2) = abs(midiRef(i,5) - midiVel(i,5));% / midiRef(i,5);
    errorMatrix(i,3) = abs(midiRef(i,5) - midiVel(i,5)) / midiRef(i,5);
end
errorMatrix(find(errorMatrix(:,1)==0) , :) =[];
for i = 1: length(numberOfNotesByError)
    numberOfNotesByError(i) = sum(errorMatrix(:,2)<=i);
end



errorAbs = sum(errorMatrix(:,2)) / length(errorMatrix); % error
errorRel = sum(errorMatrix(:,3)) / length(errorMatrix);
errorAbsSTD =std(errorMatrix(:,2));
errorRelSTD = std(errorMatrix(:,3));
%errorSTD = sqrt(sum((errorMatrix(:,2) - error).^2) / length(errorMatrix)); % error std



%hold off; plot(midiRef(:,5)); hold on; plot(midiVel(:,5), 'r'); hold off

%subplot(3,1,1); imagesc(db(X([1:200],r)+0.00001)); axis xy ; subplot(3,1,2); imagesc(Gx(:,r)); ; axis xy; subplot(3,1,3); imagesc(sheetMatrixMidiRoll(:,r)); ; axis xy
%hist(20*log10(gainData.^2+0.00001), 100)


%intensityRef = betaNormC(2 .^ (midiRef(:,5) * 0.04),2);
%intensityVel = betaNormC(gainData,2);

% intensityRef = betaNormC(midiRef(:,5),2);
% intensityVel = betaNormC(midiVel(:,5),2);
intensityRef = betaNormC(gainFromVelVec,2);
intensityVel = betaNormC(gainCalculatedVec,2);


normalizedError = sum( abs( intensityRef - intensityVel) ./ intensityRef ) / length(intensityRef);
normalizedSTD = std(abs( intensityRef - intensityVel) ./ intensityRef );
error = [errorAbs; errorAbsSTD; errorRel; errorRelSTD;  normalizedError; normalizedSTD];


errorPerNote = zeros(2, max(errorMatrix(:,1)));
for i = 1 : length(errorMatrix)
    errorPerNote(1,errorMatrix(i,1)) = errorPerNote(1,errorMatrix(i,1)) + errorMatrix(i,2);
    errorPerNote(2,errorMatrix(i,1)) = errorPerNote(2,errorMatrix(i,1)) + 1;
end
errorPerNoteResult = errorPerNote(1,:) ./ errorPerNote(2,:);

refVelCompare = zeros(length(midiRef), 3);
refVelCompare(:,1:2) = midiRef(:,4:5);
refVelCompare(:,3) = midiVel(:,5);




end