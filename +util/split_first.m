function arr = split_first(arr, sz)
% split_first Split the input ndarray along the first dimension into two new
%consecutive dimensions, the product of which is equal to the original
%size of the splitted dimension    
% Copyright 2022 Jorge Ibáñez Gijón

        
    if length(sz) > 2
        %recursive call the function if sz > 2
        %keep the two first dimensions to be split here, and pass
        %the rest of sz split dimensions to the next call in the chain
        newsz = [sz(1)*sz(2), sz(3:end)];
        arr = split_first(arr,newsz);
        sz = sz(1:2);
    end
    osz = size(arr);
    nsz = [sz,osz(2:end)];    
    arr = reshape_ndarray(arr, nsz);
end
