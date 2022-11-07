function [isa_arr, cometa_arr, hr_arr, ppcorr] = get_pp_data_at_ISA(ppdata, fcns, env, envhr, doplot)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, fcns = {@nanmax, @nanmax, @nanmax}; end
    if nargin < 3, env = 14; end
    if nargin < 4, envhr = 7; end
    if nargin < 5, doplot=false; end
    
    isa_names = fieldnames(ppdata.ISA);
    cometa_names = fieldnames(ppdata.cometa);
    order = ppdata.order(2:2:12);
    xp_conditions = 6;
    isa_points = 8;
    sz = xp_conditions*isa_points;
    cometa_arr = nan(1,sz);
    isa_arr = nan(1,sz);
    hr_arr = nan(1,sz);
    groups = nan(1,sz);
    idx = 0;
    for cno=1:length(isa_names)
        isa_name = isa_names{cno};
        cometa_name = cometa_names{cno};
        ts_trial_number = ismember(order,isa_name);
        isa_data = ppdata.ISA.(isa_name);
        cometa_data = ppdata.cometa.(cometa_name).COMETA;
        hr_data = ppdata.timeseries.HR.trials{ts_trial_number};
        for t=2:2:16
            idx = idx + 1;
            isa_val_name = ['ISA_' isa_name '_' num2str(t)];
            
            tidx_c = t * 60;
            % Some time series of COMETA are smaller than 960 points
            % This is a small experimental error, just avoid it.
            if tidx_c > length(cometa_data)
                tidx_c = length(cometa_data);
            end
            if iscell(fcns)
                isa_arr(idx) = fcns{1}(isa_data.(isa_val_name));
                cometa_arr(idx) = fcns{2}(cometa_data(tidx_c-env:tidx_c));
                hr_arr(idx) = fcns{3}(hr_data(tidx_c-envhr:tidx_c));
            else
                isa_arr(idx) = fcns(isa_data.(isa_val_name));
                cometa_arr(idx) = fcns(cometa_data(tidx_c-env:tidx_c));
                hr_arr(idx) = fcns(hr_data(tidx_c-envhr:tidx_c));
            end
            groups(idx) = cno;
        end
    end       
    
    %Run correlation analysis
    tmp = corrcoef([isa_arr; cometa_arr; hr_arr]');
    ppcorr = [tmp(1,2);tmp(1,3);tmp(2,3)]';
        
    if doplot
        ext = '.png';
        figname = [ppdata.name '_at_ISA' ext];
        plot_pp_correlations(isa_arr, cometa_arr, hr_arr, groups, ppcorr, ppdata.name, figname, doplot)
    end
end

