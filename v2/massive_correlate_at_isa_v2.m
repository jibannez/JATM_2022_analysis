function [M, R, PValue, conf] = massive_correlate_at_isa_v2(xp, conf)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2; conf = struct();end
    
    import util.reshape_ndarray
   
    thr = 0.4;
    
    [M, conf] = getdata4correlations(xp, 'atisa', conf);    
    [ppno, cno, isano, vno] = size(M);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    ppnames = cell(ppno,1);
    for pp = 1:ppno
        ppnames{pp} = ['P_' num2str(pp)];
    end
    
    % Put variables in the first dimension and merge participants and
    % conditions
    M = permute(M,[4,1,2,3]);
    M = reshape_ndarray(M,[vno, ppno*cno*isano]);

    % Run massive correlations for all conditions
    figTitle = 'Massive correlations between performance, complexity and physiological variables. ALL CONDITIONS';
    [R,PValue] = util.fcnCorrMatrixPlot(M',conf.vnames,figTitle);
    util.print_sgn_correlations(R, conf.vnames, thr)
    
    % Add some information to conf struct
    conf.ppnames = ppnames;
    conf.cnames = cnames;
end
