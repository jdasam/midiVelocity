filelist= getFileListWithExtension('*.wav');

stat = zeros(length(filelist),4);

for i=1:length(filelist)
    filename = filelist{i};
    
    csvname = strcat(filename, '.wav.mat.csv');
    midiname = strcat(filename, '.mid');
    
    nmat= readmidi_java(midiname);
    estimate = csvread(csvname);
    
    
    stat(i,1) = mean(nmat(:,5));
    stat(i,2) = std(nmat(:,5));
    stat(i,3) = mean(estimate);
    stat(i,4) = std(estimate);
    
end

%%

[RHO,PVAL] = corr(statAm(:,2),statAm(:,4),'type','pearson')

subplot(1,2,1)
hold off
scatter(statAm(:,1), statAm(:,3), 150, 'filled')
hold on
scatter(statCl(:,1), statCl(:,3), 150, 's','filled')

ylabel('Estimated Mean by NN', 'FontSize', 35, 'FontName', 'Arial')
xlabel('Ground Truth Mean', 'FontSize', 35, 'FontName', 'Arial')
set(gca, 'FontName', 'Arial', 'FontSize', 25);
[~,b] = legend('Ambient Recording', 'Close Recording');
set(findobj(b,'-property','MarkerSize'),'MarkerSize',20)

subplot(1,2,2)
hold off
scatter(statAm(:,2), statAm(:,4), 150, 'filled')

hold on
scatter(statCl(:,2), statCl(:,4),150, 's','filled')
ylabel('Estimated Std by NN', 'FontSize', 35, 'FontName', 'Arial')
xlabel('Ground Truth Std', 'FontSize', 35, 'FontName', 'Arial')
set(gca, 'FontName', 'Arial', 'FontSize', 25);
[~,b] = legend('Ambient Recording', 'Close Recording');
set(findobj(b,'-property','MarkerSize'),'MarkerSize',20)

