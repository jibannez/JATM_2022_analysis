function stepwise_regress_isa_vs_cometa_at_isa(xp, fcn, env)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcn = @nanmax; end
    if nargin < 3, env = 10; end
    
    import util.reshape_ndarray
        
    [M, vnames] = get_cometa_matrix_at_isa(xp, fcn, env);
    [ppno, cno, isano, vno] = size(M);
    M2 = reshape_ndarray(M,[ppno*cno*isano, vno]);
    ISA = M2(:,1);
    COMETA_COMPONENTS = M2(:, 2:end);
    %COMETA_COMPONENTS = [M2(:, 2:end), M2(:, 2).*M2(:, 2), M2(:, 3).*M2(:, 3), M2(:, 4).*M2(:, 4), M2(:, 5).*M2(:, 5), M2(:, 6).*M2(:, 6)] ;
    stepwise(COMETA_COMPONENTS, ISA)
end


