targetPitch = 50;
i = targetPitch;
dataSize = min(find(xdata(:,i)==0)) -1;
[lassoAll, stats] = lasso(xdata(1:max(find(xdata(:,i))),i), log(ydata(1:max(find(xdata(:,i))),i)), 'CV', 5);
fittingArray = [lassoAll(stats.IndexMinMSE); stats.Intercept(stats.IndexMinMSE);];


scatter(xdata(:,targetPitch), log(ydata(:,targetPitch)), 'filled', 'LineWidth', 4);
hold on

x = [1:1:110];
y = fittingArray(1) * x + fittingArray(2);
plot(x,y, 'LineWidth', 3, 'Color', 'k')

hold off


xlabel('MIDI Velocity', 'FontSize', 40, 'FontName', 'Times');
ylabel('Estimated Intensity (log)', 'FontSize', 40, 'FontName', 'Times');
%title('', 'FontSize', 30, 'FontName', 'Times')

legend({'Note data', 'Mapping curve'}, 'FontSize', 30, 'FontName', 'Times', 'Location','northwest')