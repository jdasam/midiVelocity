resultList ={};

%  resultCodeList = {'Bd' ,'BdR2', 'BdHc', 'BdR2GfHc' ,'BdR2GfHcUibId10', 'R1', 'R2', 'R2Gf', 'R2Hc', 'R2GfHc', 'R2GfHcUbn5', 'R2GfHcGpr5Ubn5'};
%resultCodeList = {'BdR2GfHcUibId10','BdR2S2GfHcUibId10','BdR2S2GfHcUibId10A1' , 'BdR2S2GfHcUibId10A10', 'BdR2S2GfHcUibId10A100', 'R2S2GfHcGpr5Ubn5', 'R2S2GfHcGpr5Ubn5A10', 'R2S2GfHcGpr5Ubn5A100'};
% resultCodeList = {'R4S2BdGpr20Ubn5aa5Uib', 'R5S2BdGpr20Ubn5aa5Uib', 'R6S2BdGpr20Ubn5aa5Uib', 'R5S2BdGpr20Ubn5aa5UibId50', 'R5S2BdUbn5Gpr20aa5', 'R5S2BdGpre20aa5Uib', 'R5S2BdUbn5Gpr20aa20Uib'};
% resultCodeList = {'R2', 'R2scale', 'R10', 'R10scale'};
resultCodeList = {'HarmPerc', 'HarmPerc_scale', 'Multi', 'Multi_scale'};


for i = 1:length(resultCodeList)
    tempResult = strcat('resultData', resultCodeList{i});   
    eval(['resultList{i} = ', tempResult ';']);
    
end

%resultList = {resultDataBasic, resultDataR2Gf,  resultDataBdR2GfHc, resultDataR2GfHc, resultDataBdR2GfUibBpuId10, resultDataR2GfHcGpr5Ubn5, };
resultAverage = [];

for i=1:length(resultList)
    
    resultAverage(i, 1) = mean(resultList{i}.error(5,:)*100);
    resultAverage(i, 2) = mean(resultList{i}.error(6,:)*100);
%     resultAverage(i, 3) = std(resultList{i}.error(5,:)*100);
%     resultAverage(i, 4) = std(resultList{i}.error(6,:)*100);

end


barGraph = bar(resultAverage(:,1:2));
barGraph(1).FaceColor = 'k';
barGraph(2).FaceColor = 'w';
barGraph(2).LineWidth = 2;

ylim([5 26])
xlim([0 length(resultCodeList)+1])
%hold on;
%h=errorbar(resultAverage(:,1:2),resultAverage(:,3:4),'c'); set(h,'linestyle','none')
% hold off



% set(gca, 'XTickLabel', resultCodeList, 'FontName', 'Arial', 'FontSize', 20)
set(gca, 'XTickLabel', {'Harm-perc', 'Harm-perc + scale', 'Multi', 'Multi + scale'}, 'FontName', 'Arial', 'FontSize', 20)
ylabel('Relative Error (%)', 'FontSize', 30)

legend({'Piecewise Average of Mean Error', 'Piecewise Average of Error STD'})

%%
plot(resultDataBdR2GfHc.error(1,:))
hold on
plot(resultDataR2GfHc.error(1,:))
plot(resultDataBdR2GfUibBpuId10.error(1,:))
hold off



%%

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
basicParameter.alpha = 1;
resultName = 'BdR2GfHcUibId10A1';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
basicParameter.alpha = 10;
resultName = 'BdR2GfHcUibId10A10';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
basicParameter.alpha = 100;
resultName = 'BdR2GfHcUibId10A100';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
basicParameter.alpha = 20;
resultName = 'BdR2GfHcUibId10A20';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
basicParameter.alpha = 5;
resultName = 'BdR2GfHcUibId10A5';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.basisSource = 'data';
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.useInitialB = true;
basicParameter.iterationData = 10;
basicParameter.alpha = 0.1;
resultName = 'BdR2GfHcUibId10A01';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 0.1;
resultName = 'BdR2GfHcGpr5Ubn5A01';
autoVelExtractSystem(basicParameter, dirSet, resultName);


basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
resultName = 'R2GfHcGpr5Ubn5';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 1;
resultName = 'R2GfHcGpr5Ubn5A1';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 10;
resultName = 'BdR2GfHcGpr5Ubn5A10';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 20;
resultName = 'BdR2GfHcGpr5Ubn5A20';
autoVelExtractSystem(basicParameter, dirSet, resultName);

basicParameter = basicParameterInitialize();
basicParameter.rankMode = 2;
basicParameter.Gfixed = true;
basicParameter.harmConstrain = true;
basicParameter.GpreUpdate = 5;
basicParameter.updateBnumber = 5;
basicParameter.alpha = 100;
resultName = 'BdR2GfHcGpr5Ubn5A100';
autoVelExtractSystem(basicParameter, dirSet, resultName);