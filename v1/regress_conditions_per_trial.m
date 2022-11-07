function [b,bint,r,rint,stats, vnames] = regress_conditions_per_trial(xpdata, fcncorrelates, fcnperf, add_cometa_components)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcncorrelates = {@nanmax, @nanmax, @nanmax}; end
    if nargin < 3, fcnperf = @nanmax; end
    if nargin < 4, add_cometa_components = false; end
    
    import util.reshape_ndarray
        
    [M, vnames] = get_full_matrix_per_trial(xpdata, fcncorrelates, fcnperf, false, add_cometa_components);
    [ppno, cno, vno] = size(M);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    ppnames = cell(ppno,1);
    for pp = 1:ppno
        ppnames{pp} = ['P_' num2str(pp)];
    end
    
    %add a final variable that encodes for the experimental condition
    for cn = 1:cno
        if cn < 4
            M(:,cn,vno+1) = cn-4;
        else
            M(:,cn,vno+1) = cn-3;
        end
    end

    %reshape and distribute model matrix and response vector
    M2 = reshape_ndarray(M,[ppno*cno, vno+1]);
    Y = M2(:,end);
    
    %add constant for intercept term
    M2(:,end)=1;
    vnames{end} = 'Intercept';
     
    [b,bint,r,rint,stats] = regress(Y,M2);

end

