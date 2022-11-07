function xp = add_EDA_components(xp)
% add_EDA_components Add EDA values to xp processing
% Copyright 2022 Jorge Ibáñez Gijón

    % Global EDA parameters
    tau1 = 0.7;
    delta = 1/4;
    delta_knot = 5;
    alpha = 0.0008;
    gamma = 0.01;    
    solver = 'quadprog';
    nyqfreq = 8;
    cutoff = .9;
    
    %Create rows one by one, iterating over all possible values
    participants = fieldnames(xp.active);
    for ppno=1:length(participants)
        ppname = participants{ppno};
        % Local copies of relevant data structures, to unclutter code
        eda = xp.active.(ppname).timeseries.EDA;
        eda.global = struct;
        %[eda.global.y, eda.global.mean, eda.global.std] = zscore(eda.values);
        eda.global.y = signal.filterdata(eda.values,cutoff,nyqfreq);
        [r, p, t, l, d, e, obj] = cvxEDA(eda.global.y, delta, eda.tau0, tau1, delta_knot, alpha, gamma, solver);
        eda.global.phasic = r;
        eda.global.pulses = p;
        eda.global.tonic = t;
        eda.global.linear = d;
        
        % Per trial structures
        eda.trials_phasic = cell(size(eda.trials));
        eda.trials_tonic = cell(size(eda.trials));
        eda.trials_pulses = cell(size(eda.trials));
        %eda.trials_mean = cell(size(eda.trials));
        %eda.trials_std = cell(size(eda.trials));
        for tr=1:length(eda.trials)
            %[trdata, edamean, edastd] = zscore(eda.trials{tr});
            trdata = signal.filterdata(eda.trials{tr}, cutoff, nyqfreq);
            [r, p, t, l, d, e, obj] = cvxEDA(trdata, delta, eda.tau0, tau1, delta_knot, alpha, gamma, solver);
            eda.trials_phasic{tr} = r;
            eda.trials_pulses{tr} = p;
            eda.trials_tonic{tr} = t;
            %eda.trials_mean{tr} = edamean;
            %eda.trials_std{tr} = edastd;
        end
        
        % Store back
        xp.active.(ppname).timeseries.EDA = eda;
    end
end
