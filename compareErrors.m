function [] =compareErrors(aResult, bResult, basicParameter, dir)


    aError = analyzeError(aResult, basicParameter, dir);
    bError = analyzeError(bResult, basicParameter, dir);

    
    for i=1:7
        plotWithIndex(aError, bError, i)
        
    end

end



function []= plotWithIndex(aError, bError, index)

    figure(index)
    hold off
    plot(aError(:,(index-1)*2+1))
    hold on
    plot(bError(:,(index-1)*2+1))
    plot(aError(:,index*2) / max(aError(:,index*2)) * ( max(aError(:,(index-1)*2+1)) - min(aError(:,(index-1)*2+1))   ) )

end