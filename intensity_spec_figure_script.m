vel1 = velocityGainMatchingCell{1,1}{1,1};
inten1 = velocityGainMatchingCell{1,1}{1,2};

vel2 = velocityGainMatchingCell{1,2}{1,1};
inten2 = velocityGainMatchingCell{1,2}{1,2};

%%
targetPitch = 45;
hold off
scatter(vel1(:,targetPitch), log(inten1(:,targetPitch)), 40);
hold on
scatter(vel2(:,targetPitch), log(inten2(:,targetPitch)),40, 'x');

ylabel('Intensity (log)', 'FontSize', 35, 'FontName', 'Arial')
xlabel('MIDI Velocity', 'FontSize', 35, 'FontName', 'Arial')
title('Velocity-Intensity Mapping of Two Datasets',  'FontSize', 35, 'FontName', 'Arial')
set(gca, 'FontName', 'Arial', 'FontSize', 25);

[~,b] = legend('Recorded 2009', 'Recorded 2011');
% [~, hobj, ~, ~] = legend(h1, 'Recorded 2009', 'Recorded 2011');
% hobj(2).Children.MarkerSize = 20;
% [~, hobj2, ~, ~] = legend(h2,'Recorded 2011');
% hobj2(2).Children.MarkerSize = 20;
set(findobj(b,'-property','MarkerSize'),'MarkerSize',20)


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