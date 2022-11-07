function [M2, vnames, D] = massive_correlate_by_pp_per_trial(xpdata, fcncorrelates, fcnperf, addcometacomponents)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcncorrelates = {@nanmax, @nanmax, @nanmax}; end
    if nargin < 3, fcnperf = @nanmax; end
    if nargin < 4, addcometacomponents = false; end
    import util.reshape_ndarray
    import util.cartesian_product
        
    [M, vnames] = get_full_matrix_per_trial(xpdata, fcncorrelates, fcnperf, false, addcometacomponents);
    [ppno, cno, vno] = size(M);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    ppnames = cell(ppno,1);
    for pp = 1:ppno
        ppnames{pp} = ['P_' num2str(pp)];
    end
    
    % Put variables in the first dimension and merge participants and
    % conditions
    M2 = permute(M,[3,1,2]);
    M3 = reshape_ndarray(M2,[vno, ppno*cno]);
    D = cartesian_product(ppnames, cnames);
    
    % Run massive correlations for all conditions
    figTitle = 'Massive correlations between performance, complexity and physiological variables. ALL CONDITIONS';
    [R,PValue] = util.fcnCorrMatrixPlot(M3',vnames,figTitle);
    
    % Run massive correlations for scenario A
    figTitle = 'Massive correlations between performance, complexity and physiological variables. Scenarios A-B-C';
    M3 = reshape_ndarray(M2(:,:,1:3),[vno, ppno*3]);
    [R,PValue] = util.fcnCorrMatrixPlot(M3',vnames,figTitle);
    
    % Run massive correlations for scenario F
    figTitle = 'Massive correlations between performance, complexity and physiological variables. Scenarios D-E-F';
    M3 = reshape_ndarray(M2(:,:,4:6),[vno, ppno*3]);
    [R,PValue] = util.fcnCorrMatrixPlot(M3',vnames,figTitle);

end

