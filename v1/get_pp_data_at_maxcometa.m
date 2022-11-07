function [isa_arr, cometa_arr, hr_arr, ppcorr] = get_pp_data_at_maxcometa(ppdata, doplot)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, doplot=false; end
    
    import util.flatmat
    
    isa_names = fieldnames(ppdata.ISA);
    cometa_names = fieldnames(ppdata.cometa);
    order = ppdata.order(2:2:12);
    cno = 6;
    cometa_arr = zeros(1,cno);
    isa_arr = zeros(1,cno);
    hr_arr = zeros(1,cno);
    groups = 1:cno;
    for c=1:length(isa_names)
        isa_name = isa_names{c};
        cometa_name = cometa_names{c};
        ts_trial_number = ismember(order,isa_name);
        isa_data = table2array(ppdata.ISA.(isa_name));        
        cometa_data = ppdata.cometa.(cometa_name).COMETA;
        hr_data = ppdata.timeseries.HR.trials{ts_trial_number};
        %Get intervals of TS with max cometa values
        [intervals, cometamax] = find_max_intervals(cometa_data);        
        %Iterate over intervals to store target variables values on these
        %timestamps
        hr_tmp = [];
        isa_tmp = [];
        for i=1:length(intervals)
            t = intervals{i};
            if t(2) > length(hr_data)
                continue
            end
            if isempty(hr_tmp)
                hr_tmp = flatmat(hr_data(t(1):t(2)))';
            else
                hr_tmp = [hr_tmp; flatmat(hr_data(t(1):t(2)))'];
            end
            % Turn seconds into isa periods
            isavalues = floor(round(t/60)/2);        
            if isempty(isa_tmp)
                isa_tmp = flatmat(isa_data(isavalues(1):isavalues(2)))';
            else
                isa_tmp = [isa_tmp; flatmat(isa_data(isavalues(1):isavalues(2)))'];
            end
        end
        % Store obtained values
        cometa_arr(c) = cometamax;
        isa_arr(c) = nanmean(isa_tmp);
        hr_arr(c) = nanmean(hr_tmp);            
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

function [intervals, datamax] = find_max_intervals(data)
    datamax = max(data);
    bmax = data==datamax;
    dmax = find(diff(bmax)) + 1;
    ino = length(dmax) / 2;
    
    if ino == 0.5
        intervals{1} = [dmax(1), dmax(1)+10];
    else
        ino = floor(ino);
        intervals = cell(ino,1);
        for i=1:round(ino)

            sti = (i-1)*2+1;
            intervals{i} = [dmax(sti), dmax(sti+1)];
        end
    end
end
