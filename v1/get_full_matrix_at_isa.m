function [M, vnames] = get_full_matrix_at_isa(xp, fcncorrelates, fcnperf, forcorrelations, add_cometa_components)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcncorrelates = {@nanmax, @nanmax, @nanmax}; end
    if nargin < 3, fcnperf = @nanmax; end
    if nargin < 4, forcorrelations = false; end
    if nargin < 5, add_cometa_components = true; end
    
    [Mts, vnames_ts] = get_cometa_matrix_at_isa(xp);
    [Mperf, vnames_perf] = get_performance_matrix_at_isa(xp, fcnperf, forcorrelations); 
    vnames = [vnames_ts vnames_perf];
    M = cat(4,Mts,Mperf);

end
