function dataSet = getFileListWithExtension(extension)

dataSet = cell(1,1);
fileList = dir(extension);

for i = 1:length(fileList)
   tempFileName = getfield(fileList, {i}, 'name');
   dataSet{i} = tempFileName(1:length(tempFileName)-4);
    
end