resultName = 'R8nnRegression';
path = pwd;
useNeuralNetResult = true;

basicParameter = updateBasicParam(basicParameter);
[error, midiVelCell, refVelCompareCell] = velocityWithNeuralResult(B, basicParameter, path, useNeuralNetResult);
%
save(resultName, 'error', 'midiVelCell', 'refVelCompareCell', 'B', 'basicParameter')