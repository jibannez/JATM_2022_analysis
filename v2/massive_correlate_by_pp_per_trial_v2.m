function [M2, R1, conf, D] = massive_correlate_by_pp_per_trial_v2(xp, conf)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2; conf = struct();end
    
    import util.reshape_ndarray
    import util.cartesian_product
    
    thr = 0.5;
    
    [M, conf] = getdata4correlations(xp, 'pertrial', conf);    
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
    [R1,PValue] = util.fcnCorrMatrixPlot(M3',conf.vnames,figTitle);
    util.print_sgn_correlations(R1, conf.vnames, thr)
    
%     % Run massive correlations for scenario A
%     figTitle = 'Massive correlations between performance, complexity and physiological variables. Scenarios A-B-C';
%     M3 = reshape_ndarray(M2(:,:,1:3),[vno, ppno*3]);
%     [R2,PValue] = util.fcnCorrMatrixPlot(M3',conf.vnames,figTitle);
%     util.print_sgn_correlations(R2, conf.vnames, thr)
%     
%     % Run massive correlations for scenario F
%     figTitle = 'Massive correlations between performance, complexity and physiological variables. Scenarios D-E-F';
%     M3 = reshape_ndarray(M2(:,:,4:6),[vno, ppno*3]);
%     [R3,PValue] = util.fcnCorrMatrixPlot(M3',conf.vnames,figTitle);
%     util.print_sgn_correlations(R3, conf.vnames, thr)
% 
%     % Add some information to conf struct
%     conf.ppnames = ppnames;
%     conf.cnames = cnames;
end
