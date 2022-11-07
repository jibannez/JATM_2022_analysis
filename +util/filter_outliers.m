function filtered = filterOutliers(data, nstds)
% filterOutliers Removes outliers further than n stds
% Copyright 2022 Jorge Ibáñez Gijón
    if nargin < 2, nstds = 3; end
    data = data(isfinite(data));
    filtered = data-mean(data);
    filtered = data(abs(filtered)<nstds*std(data));
end
