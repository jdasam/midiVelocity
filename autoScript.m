dirSet = {};
dirSet{1} = '/Users/Da/Documents/MATLAB/smd_three_fold/setA';
dirSet{2} = '/Users/Da/Documents/MATLAB/smd_three_fold/setB';
dirSet{3} = '/Users/Da/Documents/MATLAB/smd_three_fold/setC';
%%
errorType = 1;
plot(resultDataR2Gf.error(errorType,:))
hold on
plot(resultDataR2GfGpuI150.error(errorType,:))
plot(resultDataR2.error(errorType,:))
hold off


%%
plot(resultDataBdR2GfHcUibId10.error(errorType,:))
hold on
plot(resultDataBdR2GfHcUibId10A1.error(errorType,:))
plot(resultDataBdR2GfHcUibId10A10.error(errorType,:))
%plot(resultDataBdR2GfHcUibId10A100.error(5,:))
hold off

%% G partial update is useless?

% Ubn을 써보자
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.GpartialUpdate = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
resultName = 'R2GfGpuGpr5Ubn5';
autoVelExtractSystem(basicParameter, dirSet, resultName);

% Hc, Ubn을 써보자
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.GpartialUpdate = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
resultName = 'R2GfGpuHcGpr5Ubn5';
autoVelExtractSystem(basicParameter, dirSet, resultName);

% Data 템플릿이랑 결합할 때는?
basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.GpartialUpdate = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 5;
basicParameter.iterationData = 10;
resultName = 'BdR2GfGpuUibGpr5Id10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

% Data 템플릿이랑 결합할 때 + Hc는?
basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.GpartialUpdate = true;
basicParameter.harmonicConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 5;
basicParameter.iterationData = 10;
resultName = 'BdR2GfGpuHcUibGpr5Id10';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
resultName = 'B1';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.beta = 0; 
resultName = 'B0';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.beta = 0;
basicParameter.spectrumMode = 2;
resultName = 'B0S2';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.beta = 2; 
resultName = 'B2';
autoVelExtractSystem(basicParameter, dirSet, resultName);

%%

% 최상 세팅 + 따른 짓
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 2;
resultName = 'R2GfHcGpr5Ubn5S2';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 1.2;
resultName = 'R2GfHcGpr5Ubn5S12';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 1.5;
resultName = 'R2GfHcGpr5Ubn5S15';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 1;
resultName = 'R2GfHcGpr5Ubn5A1';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 0.1;
resultName = 'R2GfHcGpr5Ubn5A01';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 0.3;
resultName = 'R2GfHcGpr5Ubn5A03';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 3;
resultName = 'R2GfHcGpr5Ubn5A3';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 10;
resultName = 'R2GfHcGpr5Ubn5A10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

% weight
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.weightOnAttack = ture;
resultName = 'R2GfHcGpr5Ubn5Woa';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 2;
basicParameter.alpha = 1;
resultName = 'R2GfHcGpr5Ubn5S2A1';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 2;
basicParameter.alpha = 0.1;
resultName = 'R2GfHcGpr5Ubn5S2A01';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmonicConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 2;
basicParameter.alpha = 10;
resultName = 'R2GfHcGpr5Ubn5S2A10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

%%
basicParameter = basicParameterInitialize();
basicParameter.beta = 0; 
resultName = 'B0';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.beta = 2; 
resultName = 'B2';
autoVelExtractSystem(basicParameter, dirSet, resultName);






%%

basicParameter = basicParameterInitialize();
basicParameter.scale = 'erbt';
resultName = 'Erbt';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.scale = 'erbt';
basicParameter.alpha = 10;
resultName = 'ErbtA10';
autoVelExtractSystem(basicParameter, dirSet, resultName);