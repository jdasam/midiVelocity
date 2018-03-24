function stat= readMIDIinFolderAndCalStat(path)

if nargin<1
    path = pwd;
end


fileList = getFileListWithExtension('*.mid');
stat = zeros(length(fileList),2);


for i=1:length(fileList)
    midiName = strcat(fileList{i},'.mid');
    nmat = readmidi_java(midiName);
    vel = nmat(:,5);
    stat(i,:) = [mean(vel), std(vel)*sqrt(2) ];
   

end