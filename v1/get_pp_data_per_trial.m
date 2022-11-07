function [isa_arr, cometa_arr, hr_arr, ppcorr] = get_pp_data_per_trial(ppdata, fcns, doplot)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcns = {@nanmax, @nanmax, @nanmax}; end
    if nargin < 3, doplot=false; end
    
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    order = ppdata.order(2:2:12);
    cometa_arr = nan(1,cno);
    isa_arr = nan(1,cno);
    hr_arr = nan(1,cno);
    groups = 1:cno;
    
    for cn=1:cno
        % Fetch name of this condition
        cname = cnames{cn};
        ts_trial_number = ismember(order,cname);
        
        % Fetch data for this condition
        isa_data = table2array(ppdata.ISA.(cname));
        cometa_data = ppdata.cometa.(cname).COMETA;
        hr_data = ppdata.timeseries.HR.trials{ts_trial_number};
        
        %Store max value of cometa, hr, and isa for this condition
        if iscell(fcns)            
            isa_arr(cn) = fcns{1}(isa_data(1:end-1));
            cometa_arr(cn) = fcns{2}(cometa_data);
            hr_arr(cn) = fcns{3}(hr_data);
        else
            cometa_arr(cn) = fcns(cometa_data);
            isa_arr(cn) = fcns(isa_data(1:end-1));
            hr_arr(cn) = fcns(hr_data);
        end
    end
    
    %Compute correlations
    tmp = corrcoef([isa_arr; cometa_arr; hr_arr]');
    ppcorr = [tmp(1,2);tmp(1,3);tmp(2,3)]';
        
    if doplot
        ext = '.png';
        figname = [ppdata.name '_per_trial' ext];
        plot_pp_correlations(isa_arr, cometa_arr, hr_arr, groups, ppcorr, ppdata.name, figname, doplot)
    end
    
end

