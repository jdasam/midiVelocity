function [] = checkCorrespOrderInFolder(dir)
    if nargin<1
        dir = pwd;
    end
        
    list = getFileListWithExtension('*.txt');
    
    for i = 1:length(list)
        filename = strsplit(list{i}, '_corresp');
        txtname = strcat(list{i}, '.txt');
        midiname = strcat(filename{1}, '.mid');
        
        corresp = loadCorresp(txtname);
        midi = readmidi_java(midiname);
        
        filename{1}
        checkCorrespOrder(corresp, midi)
    
    end
    
    
end


function [] = checkCorrespOrder(corresp, midi, compareRefVel)
    correspDouble = cellfun(@(x)str2double(x), corresp);
    emptyNotes = find(midi(:,2)==0);
    copmareRefVelBackup = compareRefVel;
    
    if ~isempty(emptyNotes)
         for i=1:length(emptyNotes)
            midi(emptyNotes(i),:) = [];
            if midi(emptyNotes(i),4) == compareRefVel(emptyNotes(i), 1)
                compareRefVel(emptyNotes(i),:) = [];
            else
                index=findFromCorresp(midi(emptyNotes(i),:), correspDouble);
                compareRefVel(index,:) = [];
            end
         end
    end
    
    
    for i = 1:length(midi)
        
        if correspDouble(i,4) ~= midi(i,4)
            index=findFromCorresp(midi(i,:), correspDouble);
            compareRefVel(i,:) = copmareRefVelBackup(index,:);
        end
    end
end


function index=findFromCorresp(midinote, correspDouble)
    
    candidateList = find( abs(correspDouble(:,2) - midinote(6)) < 0.0001);

    for j=1:length(candidateList)
        % compare pitch, and check not missed
        if correspDouble(candidateList(j),4)  == midinote(4) 
            index= candidateList(j);
            return
        end
    end

    

end




