function [beta,Sigma,E,CovB,logL,vnames] = mvregress_conditions_per_trial(xpdata, fcncorrelates, fcnperf, add_cometa_components)
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
    
    %add two final variables that encode for the experimental conditions
    for cn = 1:cno
        if cn < 4
            M(:,cn,vno+1) = 1;
            M(:,cn,vno+2) = cn;
        else
            M(:,cn,vno+1) = 2;
            M(:,cn,vno+2) = cn-3;
        end
    end
    
    M2 = reshape_ndarray(M,[ppno*cno, vno+2]);
    Y = M2(:,end-1:end);
    X = M2(:,1:end-2);
    [beta,Sigma,E,CovB,logL] = mvregress(X,Y);

end

