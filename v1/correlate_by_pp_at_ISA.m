function [correlations, isa_idx, cometa, hr] = correlate_by_pp_at_ISA(xpdata, fcns, env, envhr, doplot)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcns = {@nanmax, @nanmax, @nanmax}; end
    if nargin < 3, env = 7; end
    if nargin < 4, envhr = 14; end
    if nargin < 5, doplot = false; end
    
    ppnames = fieldnames(xpdata.active);
    ppno = length(ppnames);
    correlations = nan(ppno,3);
    xp_conditions = 6;
    isa_points = 8;
    sz = xp_conditions * isa_points;
    isa_idx = zeros(ppno, sz) * NaN;
    cometa = zeros(ppno, sz) * NaN;
    hr = zeros(ppno, sz) * NaN;     
    for pp=1:ppno
        ppname = ppnames{pp};
        ppdata = xpdata.active.(ppname);
        [isa_arr, cometa_arr, hr_arr, ppcorr] = get_pp_data_at_ISA(ppdata, fcns, env, envhr, doplot);
        %disp(['Correlation between ISA and COMETA for ' ppname])     
        correlations(pp,:) = ppcorr;
        % isa vs cometa   | isa vs HR  | cometa vs HR
        isa_idx(pp,:) = isa_arr;
        cometa(pp,:) = cometa_arr;
        hr(pp,:) = hr_arr;
    end
end

