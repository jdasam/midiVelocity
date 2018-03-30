resultName = 'R8baseLine';
path = pwd;
testMode = 'bl';

basicParameter = updateBasicParam(basicParameter);
[error, midiVelCell, refVelCompareCell] = velocityWithNeuralResult(B, basicParameter, path, testMode);
%
save(resultName, 'error', 'midiVelCell', 'refVelCompareCell', 'B', 'basicParameter')