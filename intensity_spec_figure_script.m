vel1 = velocityGainMatchingCell{1,1}{1,1};
inten1 = velocityGainMatchingCell{1,1}{1,2};

vel2 = velocityGainMatchingCell{1,2}{1,1};
inten2 = velocityGainMatchingCell{1,2}{1,2};

%%
targetPitch = 51;
hold off
scatter(vel1(:,targetPitch), log(inten1(:,targetPitch)))
hold on

scatter(vel2(:,targetPitch), log(inten2(:,targetPitch)), 'x')
%%
index = 216;
index2 = 258;
targetPitch = 30;
spec1 = velocityGainMatchingCell{1,1}{1,4}{index,targetPitch};
velLabel = velocityGainMatchingCell{1,1}{1,3}(index,targetPitch);
spec2 = velocityGainMatchingCell{1,1}{1,4}{index2,targetPitch};
velLabel2 = velocityGainMatchingCell{1,1}{1,3}(index2,targetPitch);
subplot(1,2,1)
imagesc(spec1.^0.6)
axis 'xy'
subplot(1,2,2)
imagesc(spec2.^0.6  )
axis 'xy'