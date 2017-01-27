function subFoldersName = returDirFoldersInFolder(dirPath)

if nargin == 1
    files = dir(dirPath);
else
    dirPath = pwd;
    files = dir(dirPath);
end
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags);
subFolders(1:2) = [];
subFoldersName = {};
for i = 1:length(subFolders)
    subFoldersName{i} = strcat(dirPath, '/',  char(subFolders(i).name));
end



end