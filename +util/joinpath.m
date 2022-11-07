function catPath = joinpath(dir1,dir2)
% joinpath Concatenates paths on a SO dependent way
% Copyright 2022 Jorge Ibáñez Gijón
    import util.joinpath
    
    if nargin == 1
        if iscell(dir1)
            dirlist = dir1;
            dir1 = dirlist{1};
            dir2 = dirlist{end};
            for dirN=2:length(dirlist)-1
                dir1 = joinpath(dir1,dirlist{dirN});
            end
        else
            error('Need two strings or a cell array of strings')
        end
    end

    if ispc
        sep='\';
    else
        sep='/';
    end
    catPath = strcat(dir1,sep,dir2);
end
