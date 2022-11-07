function out = dir2(dirname)
% dir2 Removes annoying outputs '..' and '.' of dir in Unixes
% Copyright 2022 Jorge Ibáñez Gijón.

    function bRes = notParent(name)
        if strcmp(name,'.') || strcmp(name,'..')
            bRes = false;
        else
            bRes = true;
        end
    end
    out = dir(dirname);
    out = out(cellfun(@notParent,{out(:).name}));
end
