function out = flatmat(mat)
% flatmat Flattens the input array, from any kind of shape, into [1, numel] shape
% Copyright 2022 Jorge Ibáñez Gijón
    mat = permute(mat,fliplr(1:ndims(mat)));
    out = flipud(mat(:)');
end
