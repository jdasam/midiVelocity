hold off
bar(resultData.error(1,:))
% plot(resultData.error(1,:))

hold on

highSimulRatio = zeros(1,length(errorBySimulCell));
highSimulThreshold = 5;

lowPitchRatio = zeros(1,length(errorBySimulCell));
lowPitchThreshold = 40;

lowVelRatio = zeros(1,length(errorBySimulCell));
lowVelThreshold = 20;

for i = 1:length(errorBySimulCell)
    
    highSimulRatio(i) = sum(errorBySimulCell{1,i}(highSimulThreshold:end,2)) / sum(errorBySimulCell{1,i}(:,2));
    lowPitchRatio(i) = sum(errorByPitchCell{1,i}(1:lowPitchThreshold,2))/ sum(errorByPitchCell{1,i}(:,2));
    lowVelRatio(i) = sum(errorByVelCell{1,i}(1:lowVelThreshold,2))/ sum(errorByVelCell{1,i}(:,2));
end

% plot(highSimulRatio * 20)
plot(highSimulRatio* 20)
plot(lowPitchRatio* 20)
plot(lowVelRatio* 20)

% bar([resultData.error(1,:)', highSimulRatio'*20 lowPitchRatio'*20])

%%

[RHO,PVAL] = corr(resultData.error(1,:)',lowVelRatio','type','spearman')
hold off
scatter(resultData.error(1,:), highSimulRatio)
hold on
scatter(resultData.error(1,:), lowPitchRatio*5)
scatter(resultData.error(1,:), lowVelRatio*5)
hold off
