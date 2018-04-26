function image = scatterInImagesc(dataX, dataY)
    
    minX = min(dataX);
    maxX = max(dataX);
    minY = min(dataY);
    maxY = max(dataY);


    image = zeros(maxX-minX+1, maxY-minY+1);
    
    for i=1:length(dataX)
        image(dataX(i)-minX+1, dataY(i)-minY+1) = image(dataX(i)-minX+1, dataY(i)-minY+1)+1;
        
        
    end

    imagesc(image)
    axis xy

end