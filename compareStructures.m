function compareStructures(param1, param2)
    param1= updateBasicParam(param1);
    param2= updateBasicParam(param2);
%     compParam = basicParameterInitialize();
    fieldList = fieldnames(param1);
    for i=1:length(fieldList)
        eval(strcat( 'a = param1.', fieldList{i}, ';'))
        eval(strcat( 'b = param2.', fieldList{i}, ';'))
        
        if size(a) == size(b)
            if ~ (a == b)
                fieldList{i}
            end
        else
            fieldList{i}
        end
    end
        

end