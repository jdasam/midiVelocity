function pedalDouble = readPedalCsv(csvname)

    fid = fopen(csvname, 'r');
    pedalInf = textscan(fid, '%s', 'Delimiter',',');
    pedalInfShape = reshape(pedalInf{1}, [2,length(pedalInf{1})/2])';
    pedalDouble = cellfun(@(x)str2double(x),pedalInfShape);
        
end