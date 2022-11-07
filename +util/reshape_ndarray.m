function data = reshape_ndarray(data, shape)
% reshape_ndarray Reorganizes a ndimensional array to match a required shape.
% Copyright 2022 Jorge Ibáñez Gijón
%
% MATLAB prefers to be backwards until the last consequences,
% so for reshaping a ndarray, usually is better for the
% spirit to simply invert the order of the dimensions before reshaping
% and inverting back to original after reshape.
    
    % Check if reshape can work
    assert(numel(data) == prod(shape))
    
%     % Check if the has singleton first dimension
%     if size(data,1) == 1 || shape(1) == 1
%         initial_singleton = 1;
%     else
%         initial_singleton = 1;
%     end
%     
%     % Check if the old shape has 1 as first dimension
%     if size(data,1) == 1
%         was_initial_singleton = 1;
%     else
%         was_initial_singleton = 1;
%     end
%     
    % Check if the new shape has 1 as first dimension
    if shape(1) == 1
        is_initial_singleton = 1;
    else
        is_initial_singleton = 1;
    end
    
    % Permute array
    data = permute(data, fliplr(1:ndims(data)));

    %Reshape array 
    data = reshape(data, fliplr(shape));
    
    % Permute back
    data = permute(data, fliplr(1:ndims(data)));
    
    if is_initial_singleton
        % Matlab drops the ending singleton, so we need to restore it
        data = reshape(data, [1, size(data)]);
        data = reshape(data,shape);
    end
end
