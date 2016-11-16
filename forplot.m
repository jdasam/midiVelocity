
nmat = basicParameter.MIDI;
ydata = zeros(24, basicParameter.maxNote - basicParameter.minNote +1);

for i = 1: basicParameter.maxNote - basicParameter.minNote +1
    velIndex = 1;
    for j = (i-1)*24 + 1: i*24
        
        index = ceil( ( nmat(j,6) *basicParameter.sr - basicParameter.window /2 )/ basicParameter.hopSize) + 1;
        pitch = nmat(j,4) - 19;
        
        if index < 1
            index = 1;
        end
        ydata(velIndex,i) = max(Gtest(pitch,index:index+3));
        
        velIndex = velIndex + 1;
    end
    
end

%%

scatter(linspace(5,120,24),log(ydata(:,1)), 'filled', 's', 'blue')
set(gca,'FontSize', 18)
xlabel('Velocity', 'FontSize', 25)
ylabel('Note Intensity (log)', 'FontSize', 25)
axis([0 127 0 9 ])

%%
vel_int = zeros (1, 127);

for i = 1:24
    vel_int(5*i) = log(ydata(i,1)) * 20;
end
plot(vel_int)


