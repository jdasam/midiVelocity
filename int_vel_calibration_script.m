fig1 = figure(1);
set(fig1, 'PaperUnits', 'points', 'PaperPosition', [0 0 1200 800])


hold off

xdata = velocityGainMatchingCell{1,1}{1,1};
ydata = velocityGainMatchingCell{1,1}{1,2};

pitch = 40;

scatter(xdata(:,pitch), log(ydata(:,pitch)), 40, [0 0.6 0], 'o', 'filled')

hold on;

xdata = velocityGainMatchingCell{4,1}{1,1};
ydata = velocityGainMatchingCell{4,1}{1,2};

scatter(xdata(:,pitch), log(ydata(:,pitch)), 40, [0.5 0 0], 's', 'filled')


xdata = velocityGainMatchingCell{1,1}{1,1};
ydata = velocityGainMatchingCell{1,1}{1,2};

pitch = pitch-12;

scatter(xdata(:,pitch), log(ydata(:,pitch)), 40, [0 0 0.8], 'd', 'filled')


xlabel('MIDI Velocity', 'FontName', 'Arial', 'FontSize', 40)

ylabel('Estimated Note Intensity (log)', 'FontName', 'Arial', 'FontSize', 40)
ylim([3 9])
set(gca, 'FontSize', 30)
[h,icons,plots,legend_text] = legend({'C4 notes in subset A', 'C4 notes in subset B', 'C3 notes in subset A'}, 'Location', 'Best', 'FontSize', 25);





for k = length(icons)/2+1 : length(icons)
icons(k).Children.MarkerSize = 15;
end

% print('fig1','-dpng','-r0')

