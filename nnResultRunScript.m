resultName = 'R8nn';
path = pwd;
useNeuralNetResult = true;


[error, midiVelCell, refVelCompareCell] = velocityWithNeuralResult(B, basicParameter, path, useNeuralNetResult);
%
save(resultName, 'error', 'midiVelCell', 'refVelCompareCell', 'B', 'basicParameter')