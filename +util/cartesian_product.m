function D = cartesian_product(cellstr1, cellstr2, joinstr)  
% cartesian_product Computes the cartesian product between two cell arrays of strings
% Copyright 2022 Jorge Ibáñez Gijón.
if nargin < 3, joinstr='_'; end

    n1 = length(cellstr1);
    n2 = length(cellstr2);
    D = cell(1,n1*n2);    
    k=0;
    for i=1:n1
        for j=1:n2
            k=k+1;
            D{1,k} = [cellstr1{i} joinstr cellstr2{j}];
        end
    end
end
