resultName = 'R8gtNewest';
path = pwd;
testMode = 'gt';

basicParameter = updateBasicParam(basicParameter);
[error, midiVelCell, refVelCompareCell] = velocityWithNeuralResult(B, basicParameter, path, testMode);
%
save(resultName, 'error', 'midiVelCell', 'refVelCompareCell', 'B', 'basicParameter')