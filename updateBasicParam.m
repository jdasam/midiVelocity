function basicParameter = updateBasicParam(basicParameter)
    
    compParam = basicParameterInitialize();
    fieldList = fieldnames(compParam);
    if length(fieldnames(basicParameter)) < length(fieldList)
        for i=1:length(fieldList)
            if ~isfield(basicParameter, fieldList{i})
                eval(strcat('basicParameter.', fieldList{i}, '= compParam.', fieldList{i}, ';'));
            end
        end
        
    end

end