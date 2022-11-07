function [corr, gcorr, data] = correlate_by_pp_at_maxcometa(xpdata, doplot)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, doplot = false; end
    
    import util.reshape_ndarray
    
    ppnames = fieldnames(xpdata.active);
    ppno = length(ppnames);
    corr = nan(ppno,3);
    cno = 6;
    data = nan(3,ppno,cno);    
    for pp=1:ppno
        ppname = ppnames{pp};
        ppdata = xpdata.active.(ppname);
        [isa_arr, cometa_arr, hr_arr, ppcorr] = get_pp_data_at_maxcometa(ppdata, doplot);
        %disp(['Correlation between ISA and COMETA for ' ppname])     
        corr(pp,:) = ppcorr;
        % isa vs cometa   | isa vs HR  | cometa vs HR
        data(1,pp,:) = isa_arr;
        data(2,pp,:) = cometa_arr;
        data(3,pp,:) = hr_arr;
    end
    data = reshape_ndarray(data,[3,ppno*cno])';
    % Remove rows with nans
    data(any(isnan(data), 2), :) = [];
    tmp = corrcoef(data);
    gcorr = [tmp(1,2);tmp(1,3);tmp(2,3)];
end

