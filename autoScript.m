dirSet = {};
% dirSet{1} = '/Users/Da/Documents/MATLAB/smd_three_fold/others';
% dirSet{2} = '/Users/Da/Documents/MATLAB/smd_three_fold/bach';
dirSet{1} = '/Users/Da/Documents/MATLAB/smd_three_fold/chopin';
%%
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.GpreUpdate = 10;
basicParameter.updateBnumber = 5;
basicParameter.fExtSecond = 0;
basicParameter.bExtSecond = 0.5;
resultName = '1115R2S2GfGpu10Ubn5bExt5';
autoVelExtractSystem(basicParameter, dirSet, resultName);
%%
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 3;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.GpreUpdate = 10;
basicParameter.updateBnumber = 5;
resultName = '1115R3S2GfGpu10Ubn5';
autoVelExtractSystem(basicParameter, dirSet, resultName);
%%
basicParameter = basicParameterInitialize();
basicParameter.window = 8192 * 2;
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.GpreUpdate = 10;
basicParameter.updateBnumber = 5;
resultName = '1115R2S2GfGpu10Ubn5W16k';
autoVelExtractSystem(basicParameter, dirSet, resultName);


%%
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.GpreUpdate = 10;

basicParameter.fittingArray = trainFitFolder(B, basicParameter, dirTrain)

%%
basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 3;
basicParameter.Gfixed = true;
basicParameter.iterationScale = 10;
resultName = 'BdR3Gf';
autoVelExtractSystem(basicParameter, dirSet, resultName);



%%
basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed=true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 10;
basicParameter.IterationData = 10;
basicParameter.alpha = 100;
basicParameter.searchRange = 9;
basicParameter.attackExceptRange = 7;
resultName = 'BdR2S2GfHcUibGpr10Id10A100Sr9';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed=true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 10;
basicParameter.IterationData = 10;
basicParameter.alpha = 100;
basicParameter.searchRange = 7;
basicParameter.attackExceptRange = 7;
resultName = 'BdR2S2GfHcUibGpr10Id10A100Sr7';
autoVelExtractSystem(basicParameter, dirSet, resultName);


%%
basicParameter.nfft=1024;
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed=true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 10;
basicParameter.IterationData = 10;
basicParameter.attackLengthFrame = 9;
basicParameter.searchRange = 15;
resultName = 'N1024_BdR2S2GfHcUibGpr10Id10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter.nfft=1024;
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed=true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 10;
basicParameter.IterationData = 10;
basicParameter.attackLengthFrame = 9;
basicParameter.searchRange = 15;
basicParameter.alpha = 100;
resultName = 'N1024_BdR2S2GfHcUibGpr10Id10A100';
autoVelExtractSystem(basicParameter, dirSet, resultName);



basicParameter.nfft=1024;
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed=true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 10;
basicParameter.IterationData = 10;
basicParameter.attackLengthFrame = 9;
basicParameter.searchRange = 15;
basicParameter.alpha = 100;
basicParameter.attackExceptRange = 13;
resultName = 'N1024_BdR2S2GfHcUibGpr10Id10A100Aer13';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter.nfft=1024;
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed=true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 10;
basicParameter.IterationData = 10;
basicParameter.attackLengthFrame = 9;
basicParameter.searchRange = 15;
basicParameter.alpha = 100;
basicParameter.attackExceptRange = 11;
resultName = 'N1024_BdR2S2GfHcUibGpr10Id10A100Aer11';
autoVelExtractSystem(basicParameter, dirSet, resultName);

%%

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 10;
basicParameter.iterationData = 10;
basicParameter.alpha = 100;
basicParameter.attackExcetRange = 10;
resultName = 'BdR2S2GfHcUibGpr10Id10A100Aer6';
autoVelExtractSystem(basicParameter, dirSet, resultName);


%%
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 10;
resultName = 'R2S2GfHcGpr5Ubn5A100';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 100;
basicParameter.attackExceptRange = 10;
resultName = 'R2S2GfHcGpr5Ubn5A100Aer10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 100;
basicParameter.attackExceptRange = 9;
resultName = 'R2S2GfHcGpr5Ubn5A100Aer9';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 10;
basicParameter.iterationData = 10;
basicParameter.alpha = 100;
basicParameter.attackExcetRange = 9;
resultName = 'BdR2S2GfHcUibGpr10Id10A100Aer9';
autoVelExtractSystem(basicParameter, dirSet, resultName);


%%
basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 5;
basicParameter.iterationData = 10;
basicParameter.alpha = 10;
basicParameter.attackExceptRange = 9;
resultName = 'BdR2S2GfHcUibGpr5Id10A10Aer9';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 5;
basicParameter.iterationData = 10;
basicParameter.alpha = 100;
basicParameter.attackExceptRange = 9;
resultName = 'BdR2S2GfHcUibGpr5Id10A100Aer9';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 10;
basicParameter.attackExceptRange = 9;
resultName = 'R2S2GfHcGpr5Ubn5A10Aer9';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 100;
basicParameter.attackExceptRange = 9;
resultName = 'R2S2GfHcGpr5Ubn5A100Aer9';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 100;
basicParameter.attackExceptRange = 10;
resultName = 'R2S2GfHcGpr5Ubn5A100Aer10';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 100;
basicParameter.attackExceptRange = 11;
resultName = 'R2S2GfHcGpr5Ubn5A100Aer11';
autoVelExtractSystem(basicParameter, dirSet, resultName);

%%
basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
resultName = 'BdR2';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.harmConstrain = true;
resultName = 'BdR2Hc';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
resultName = 'BdGfHcUibId10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
resultName = 'BdR2S2GfHcUibId10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
basicParmaeter.alpha = 1;
resultName = 'BdR2S2GfHcUibId10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
basicParmaeter.alpha = 1;
resultName = 'BdR2S2GfHcUibId10A1';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
basicParmaeter.alpha = 10;
resultName = 'BdR2S2GfHcUibId10A10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.spectrumMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
basicParmaeter.alpha = 100;
resultName = 'BdR2S2GfHcUibId10A100';
autoVelExtractSystem(basicParameter, dirSet, resultName);


%%
=======
>>>>>>> Stashed changes
dirSet{1} = '/Users/Da/Documents/MATLAB/smd_three_fold/others/setA';
dirSet{2} = '/Users/Da/Documents/MATLAB/smd_three_fold/others/setB';
dirSet{3} = '/Users/Da/Documents/MATLAB/smd_three_fold/others/setC';
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

% Hc, Ubn을 써보자
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.GpartialUpdate = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
resultName = 'R2GfGpuHcGpr5Ubn5';
autoVelExtractSystem(basicParameter, dirSet, resultName);

% Data ?????????? ?????? ?? + Hc???
basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.GpartialUpdate = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.GpreUpdate = 5;
basicParameter.iterationData = 10;
resultName = 'BdR2GfGpuHcUibGpr5Id10';
autoVelExtractSystem(basicParameter, dirSet, resultName);


%%

% ???? ???? + ???? ??
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 2;
resultName = 'R2GfHcGpr5Ubn5S2';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 1.2;
resultName = 'R2GfHcGpr5Ubn5S12';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 1.5;
resultName = 'R2GfHcGpr5Ubn5S15';
autoVelExtractSystem(basicParameter, dirSet, resultName);

%%
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 1;
resultName = 'R2GfHcGpr5Ubn5A1';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 0.1;
resultName = 'R2GfHcGpr5Ubn5A01';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 0.3;
resultName = 'R2GfHcGpr5Ubn5A03';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 3;
resultName = 'R2GfHcGpr5Ubn5A3';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 10;
resultName = 'R2GfHcGpr5Ubn5A10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

% weight
basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.weightOnAttack = true;
resultName = 'R2GfHcGpr5Ubn5Woa';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 2;
basicParameter.alpha = 1;
resultName = 'R2GfHcGpr5Ubn5S2A1';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.spectrumMode = 2;
basicParameter.alpha = 0.1;
resultName = 'R2GfHcGpr5Ubn5S2A01';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
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

%%

basicParameter = basicParameterInitialize();
resultName = 'SubSettest';
autoVelExtractSystem(basicParameter, dirSet, resultName);
