function [M, vnames] = get_full_matrix_per_trial(xp, fcncorrelates, fcnperf, forcorrelations, add_cometa_components)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcncorrelates = {@nanmax, @nanmax, @nanmax}; end
    if nargin < 3, fcnperf = @nanmax; end
    if nargin < 4, forcorrelations = false; end
    if nargin < 5, add_cometa_components = false; end
    
    [Mts, vnames_ts] = get_ts_matrix_per_trial(xp, fcncorrelates,add_cometa_components);
    [Mperf, vnames_perf] = get_performance_matrix_per_trial(xp, fcnperf, forcorrelations); 
    vnames = [vnames_ts vnames_perf];
    M = cat(3,Mts,Mperf);

end
