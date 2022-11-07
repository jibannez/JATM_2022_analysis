function print_sgn_correlations(Rho, vnames, thr)
% print_sgn_correlations Prints signed correlations
% Copyright 2022 Jorge Ibáñez Gijón

    if nargin < 3, thr = 0.6; end
    n = length(vnames);
    for i = 1:n
        for j = 1:n
            if i < j % below diagonal
                if abs(Rho(i,j)) > thr
                    disp([vnames{i} ' vs ' vnames{j} ' = ' num2str(Rho(i,j))])
                end
            end
        end
    end
end
