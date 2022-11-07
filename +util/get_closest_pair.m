function [r,c] = get_closest_pair(n)
% get_closest_pair Gets the lowest pair of rows,columns that includes n
% Copyright 2022 Jorge Ibáñez Gijón
    root = ceil(sqrt(n));
    p1 = (root - 1) * root;
    if p1 < n
        r = root;
        c = root;
    else
        r = root;
        c = root-1;
    end
end
