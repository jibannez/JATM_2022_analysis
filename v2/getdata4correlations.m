function [data, conf] = getdata4correlations(xp, dtype, conf)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, dtype = 'atisa'; end
    if nargin < 3, conf = check_conf(dtype); end

    %Set missing default values, also removes wrong conf inputs
    if isa(dtype,'char')
        conf.dtype = dtype; %  just in case
    end
    conf = check_conf(conf);

    % Run the select algoritm
    switch conf.dtype
        case 'atisa'
            M_ISA = get_isa_data_at_isa(xp, conf);
            MCometa = get_cometa_data_at_isa(xp, conf);
            MPerf = get_performance_data_at_isa(xp, conf); 
            MPhys = get_physiological_data_at_isa(xp, conf);
            data = cat(4, MCometa, MPerf, MPhys,  M_ISA);
            if conf.filteroutliers
                data = filter_outliers_4d(data);
            end
            
        case 'atextr'
            error('Not implemented')
            
        case 'pertrial'
            M_ISA = get_isa_data_per_trial(xp, conf);
            MNASA = get_nasa_data_per_trial(xp, conf);
            MCometa = get_cometa_data_per_trial(xp, conf);
            MPerf = get_performance_data_per_trial(xp, conf);
            MPhys = get_physiological_data_per_trial(xp, conf);                
            data = cat(3, MCometa, MPerf, MPhys, M_ISA, MNASA);
            if conf.filteroutliers
                data = filter_outliers_3d(data);
            end
        otherwise
            error(['Selected grouping method is not defined: ' conf.dtype])
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           REPLACE OUTLIERS BY THE MEAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = filter_outliers_3d(M,stdthr)
    if nargin < 2, stdthr = 3; end
    [ppno, cno, vno] = size(M);
    for vi=1:vno
        for ci=1:cno
            vdata = M(:,ci,vi);
            %vdata1d = util.flatmat(vdata);
            mu = nanmean(vdata);
            sigma = nanstd(vdata);
            bout = abs(vdata - mu) > stdthr*sigma;
            vdata(bout) = mu;
            M(:,ci,vi) = vdata;
        end
    end
end


function M = filter_outliers_4d(M,stdthr)
    if nargin < 2, stdthr = 3; end
    [ppno, cno, isano, vno] = size(M);
    for vi=1:vno
        for ci=1:cno
            vdata = M(:,ci,:,vi);
            
            vdata1d = util.flatmat(vdata);
            mu = nanmean(vdata1d);
            sigma = nanstd(vdata1d);
            bout = abs(vdata - mu) > stdthr*sigma;
            vdata(bout) = mu;
            M(:,ci,:,vi) = vdata;
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           PERTRIAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = get_isa_data_per_trial(xp, conf)
    if isempty(conf.vnames_isa)
        M = [];
    else    
        fcn = conf.fcn_isa;
        ppnames = fieldnames(xp.active);
        ppno = length(ppnames);
        cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
        cno = length(cnames);
        M = nan(ppno, cno, 1);    
        for ppi = 1:ppno
            ppname = ppnames{ppi};
            ppdata = xp.active.(ppname);
            for cn=1:cno
                % Fetch name of this condition
                cname = cnames{cn};
                % Add ISA data
                isa_data = table2array(ppdata.ISA.(cname));
                M(ppi,cn,1) = fcn(isa_data(1:end-1));
            end
        end
    end
end


function M = get_nasa_data_per_trial(xp, conf)
    if isempty(conf.vnames_nasa)
        M = [];
    else    
        fcn = conf.fcn_nasa;
        ppnames = fieldnames(xp.active);
        ppno = length(ppnames);
        cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
        cno = length(cnames);
        M = nan(ppno, cno, 1);    
        for ppi = 1:ppno
            ppname = ppnames{ppi};
            ppdata = xp.active.(ppname);
            for cn=1:cno
                % Fetch name of this condition
                cname = cnames{cn};
                % Add ISA data
                nasa_data = table2array(ppdata.NASA.(cname));
                %nasa = nada_data(1);
                %M(ppi,cn,1) = fcn(nasa_data(1:end));
                M(ppi,cn,1) = nasa_data(1);
            end
        end
    end
end


function M = get_cometa_data_per_trial(xp, conf)
    fcn = conf.fcn_cometa;
    ppnames = fieldnames(xp.active);
    ppno = length(ppnames);
    vno = length(conf.vnames_cometa);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    M = nan(ppno, cno, vno);    
    for ppi = 1:ppno
        ppname = ppnames{ppi};
        ppdata = xp.active.(ppname);
        for cn=1:cno
            % Fetch name of this condition
            cname = cnames{cn};
            % Add cometa data
            for vn = 1:vno
                vname = conf.vnames_cometa{vn};
                M(ppi,cn,vn) = fcn(ppdata.cometa.(cname).(vname));
            end
        end    
    end
end


function M = get_physiological_data_per_trial(xp, conf)
    fcn = conf.fcn_phys;
    ppnames = fieldnames(xp.active);
    ppno = length(ppnames);
    vno = length(conf.vnames_phys);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    M = nan(ppno, cno, vno);    
    for ppi = 1:ppno
        ppname = ppnames{ppi};
        ppdata = xp.active.(ppname);
        order = ppdata.order(2:2:12);
        for cn = 1:cno
            cname = cnames{cn};
            trno = ismember(order,cname);
            for vn=1:vno
                vname = conf.vnames_phys{vn};
                switch vname
                    case 'EDAtonic'
                        data = ppdata.timeseries.EDA.trials_tonic{trno};
                        M(ppi,cn,vn) = fcn(data);
                    case  'EDAphasic'
                        data = ppdata.timeseries.EDA.trials_phasic{trno};
                        M(ppi,cn,vn) = fcn(data);
                    case 'EDAtonicrel'
                        globalmean = nanmean(ppdata.timeseries.EDA.global.tonic);
                        data = ppdata.timeseries.EDA.trials_tonic{trno}/globalmean;
                        M(ppi,cn,vn) = fcn(data);
                    case  'EDAphasicrel'
                        globalmean = nanmean(ppdata.timeseries.EDA.global.phasic);
                        data = ppdata.timeseries.EDA.trials_phasic{trno}/globalmean;
                        M(ppi,cn,vn) = fcn(data);
                    case 'HR'
                        data = ppdata.timeseries.HR.trials{trno};
                        M(ppi,cn,vn) = fcn(data);
                    case 'IBI'
                        data = HRV.RRfilter(ppdata.timeseries.IBI2.trials{trno});
                        M(ppi,cn,vn) = nanmean(data);
                    case 'HRVSDSD'
                        data = HRV.RRfilter(ppdata.timeseries.IBI2.trials{trno});
                        M(ppi,cn,vn) = HRV.SDSD(data);
                    case 'HRVSDNN'
                        data = HRV.RRfilter(ppdata.timeseries.IBI2.trials{trno});
                        M(ppi,cn,vn) = HRV.SDNN(data);
                    case 'HRVRMSSD'
                        data = HRV.RRfilter(ppdata.timeseries.IBI2.trials{trno});
                        M(ppi,cn,vn) = HRV.RMSSD(data);
                    case 'HRVpNN50'
                        data = HRV.RRfilter(ppdata.timeseries.IBI2.trials{trno});
                        M(ppi,cn,vn) = HRV.pNN50(data);
                    case 'HRVTRI'
                        data = HRV.RRfilter(ppdata.timeseries.IBI2.trials{trno});
                        M(ppi,cn,vn) = HRV.TRI(data);
                    case 'HRVTINN'
                        data = HRV.RRfilter(ppdata.timeseries.IBI2.trials{trno});
                        M(ppi,cn,vn) = HRV.TINN(data);
                    case 'HRVrr'
                        data = HRV.RRfilter(ppdata.timeseries.IBI2.trials{trno});
                        M(ppi,cn,vn) = HRV.rrHRV(data);
                    otherwise
                        error(['Unknown variable in input: ' vname ])
                end                
            end
        end
    end
end


function M = get_performance_data_per_trial(xp, conf)
    fcn = conf.fcn_perf;
    vnames = conf.vnames_perf;
    vno = length(conf.vnames_perf);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    ppnames = fieldnames(xp.active);
    ppno = length(ppnames);
    M = nan(ppno,cno,vno);      
    for ppi = 1:ppno
        for cci = 1:cno
            cname = cnames{cci};
            ppname = ppnames{ppi};
            trdata = xp.active.(ppname).cometa.(cname);
            for vi=1:vno
                M(ppi,cci,vi) = fcn(trdata.(vnames{vi}));                
            end
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           AT ISA FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function M = get_isa_data_at_isa(xp, conf)    
    if isempty(conf.vnames_isa)
        M = [];
    else    
        fcn = conf.fcn_isa;
        ppnames = fieldnames(xp.active);
        ppno = length(ppnames);
        cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
        cno = length(cnames);
        isavalues = 2:2:16;    
        isano = length(isavalues);
        M = nan(ppno, cno, isano, 1);
        for ppi = 1:ppno
            ppname = ppnames{ppi};
            ppdata = xp.active.(ppname);
            for cn=1:cno
                cname = cnames{cn};
                isa_data = ppdata.ISA.(cname);        
                for isan=1:isano
                    t=isavalues(isan);
                    isa_vname = ['ISA_' cname '_' num2str(t)];
                    M(ppi,cn,isan,1) = fcn(isa_data.(isa_vname));                
                end
            end
        end
    end
end


function M = get_cometa_data_at_isa(xp, conf)    
    vnames = conf.vnames_cometa;
    fcn = conf.fcn_cometa;
    env = conf.env_cometa; 
    ppnames = fieldnames(xp.active);
    ppno = length(ppnames);
    vno = length(vnames);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    isavalues = 2:2:16;    
    isano = length(isavalues);
    M = nan(ppno, cno, isano, vno);
    for ppi = 1:ppno
        ppname = ppnames{ppi};
        ppdata = xp.active.(ppname);
        for cn=1:cno
            cname = cnames{cn};
            for isan=1:isano
                tidx_c = isavalues(isan) * 60;
                if tidx_c > length(ppdata.cometa.(cname).COMETA)
                    tidx_c = length(ppdata.cometa.(cname).COMETA);
                end

                %Fetch all cometa components
                for vn=1:vno
                    vname = vnames{vn};
                    data = ppdata.cometa.(cname).(vname);
                    M(ppi,cn,isan,vn) = fcn(data(tidx_c-env:tidx_c));
                end
            end
        end
    end
end


function M = get_physiological_data_at_isa(xp, conf)   
    EDAfs = 4;
    vnames = conf.vnames_phys;
    fcn = conf.fcn_phys;
    env = conf.env_phys;
    ppnames = fieldnames(xp.active);
    ppno = length(ppnames);
    vno = length(vnames);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    isavalues = 2:2:16;    
    isano = length(isavalues);
    M = nan(ppno, cno, isano, vno);
    for ppi = 1:ppno
        ppname = ppnames{ppi};
        ppdata = xp.active.(ppname);
        order = ppdata.order(2:2:12);
        for cn=1:cno
            cname = cnames{cn};
            trno = ismember(order,cname);
            for isan=1:isano
                t=isavalues(isan)*60; %seconds
                for vn=1:vno
                    vname = vnames{vn};
                    switch vname
                        case 'EDAtonic'
                            tidx_c = t * EDAfs;
                            envlocal = env * EDAfs;
                            data = ppdata.timeseries.EDA.trials_tonic{trno};
                            M(ppi,cn,isan,vn) = fcn(data(tidx_c-envlocal:tidx_c));
                        case  'EDAphasic'
                            tidx_c = t * EDAfs;
                            envlocal = env * EDAfs;
                            data = ppdata.timeseries.EDA.trials_phasic{trno};
                            M(ppi,cn,isan,vn) = fcn(data(tidx_c-envlocal:tidx_c));
                        case 'EDAtonicrel'
                            tidx_c = t * EDAfs;
                            envlocal = env * EDAfs;
                            globalmean = nanmean(ppdata.timeseries.EDA.global.tonic);
                            data = ppdata.timeseries.EDA.trials_tonic{trno}/globalmean;
                            M(ppi,cn,isan,vn) = fcn(data(tidx_c-envlocal:tidx_c));
                        case  'EDAphasicrel'
                            tidx_c = t * EDAfs;
                            envlocal = env * EDAfs;
                            globalmean = nanmean(ppdata.timeseries.EDA.global.phasic);
                            data = ppdata.timeseries.EDA.trials_phasic{trno}/globalmean;
                            M(ppi,cn,isan,vn) = fcn(data(tidx_c-envlocal:tidx_c));
                        case 'HR'
                            tidx_c = t;
                            envlocal = env;
                            data = ppdata.timeseries.HR.trials{trno};
                            M(ppi,cn,isan,vn) = fcn(data(tidx_c-envlocal:tidx_c));
                        case 'IBI'
                            data = fetch_IBI2_data_at_interval(ppdata.timeseries.IBI2, trno, t, env);
                            M(ppi,cn,isan,vn) = nanmean(data);
                        case 'HRVSDSD'
                            data = fetch_IBI2_data_at_interval(ppdata.timeseries.IBI2, trno, t, env);
                            M(ppi,cn,isan,vn) = HRV.SDSD(data);
                        case 'HRVSDNN'
                            data = fetch_IBI2_data_at_interval(ppdata.timeseries.IBI2, trno, t, env);
                            M(ppi,cn,isan,vn) = HRV.SDNN(data);
                        case 'HRVRMSSD'
                            data = fetch_IBI2_data_at_interval(ppdata.timeseries.IBI2, trno, t, env);
                            M(ppi,cn,isan,vn) = HRV.RMSSD(data);
                        case 'HRVpNN50'
                            data = fetch_IBI2_data_at_interval(ppdata.timeseries.IBI2, trno, t, env);
                            M(ppi,cn,isan,vn) = HRV.pNN50(data);
                        case 'HRVTRI'
                            data = fetch_IBI2_data_at_interval(ppdata.timeseries.IBI2, trno, t, env);
                            M(ppi,cn,isan,vn) = HRV.TRI(data);
                        case 'HRVTINN'
                            data = fetch_IBI2_data_at_interval(ppdata.timeseries.IBI2, trno, t, env);
                            M(ppi,cn,isan,vn) = HRV.TINN(data);
                        case 'HRVrr'
                            data = fetch_IBI2_data_at_interval(ppdata.timeseries.IBI2, trno, t, env);
                            M(ppi,cn,isan,vn) = HRV.rrHRV(data);
                        otherwise
                            error(['Unknown variable in input: ' vname ])
                    end
                end
            end
        end
    end
end


function M = fetch_IBI2_data_at_interval(IBI, ts_trial_number, t, env)
    data = HRV.RRfilter(IBI.trials{ts_trial_number});
    bNotNaN = ~isnan(data);
    times = IBI.trial_times{ts_trial_number};
    times = times - times(1);
    idxs = times < (t + env) & times < (t - env) & bNotNaN;
    M = data(idxs);
end


function M = get_performance_data_at_isa(xp, conf)
    vnames = conf.vnames_perf;
    fcn = conf.fcn_perf;
    env = conf.env_perf;
    ppnames = fieldnames(xp.active);
    ppno = length(ppnames);
    vno = length(vnames);
    cnames = {'A', 'B', 'C', 'D', 'E', 'F'};
    cno = length(cnames);
    isavalues = 2:2:16;
    isano = length(isavalues);
    M = nan(ppno,cno,isano,vno);
    for ppi = 1:ppno
        for cci = 1:cno
            for isai = 1:isano
                cname = cnames{cci};
                ppname = ppnames{ppi};
                trdata = xp.active.(ppname).cometa.(cname);
                tidx = isavalues(isai) * 60;
                if tidx > length(trdata.COMETA)
                    tidx = length(trdata.COMETA);                    
                end
                isainterval = tidx-env:tidx;
                for vi=1:length(vnames)
                    data = trdata.(vnames{vi})(isainterval);
                    if iscell(fcn)
                        M(ppi,cci,isai,vi) = fcn{vi}(data);           
                    else
                        M(ppi,cci,isai,vi) = fcn(data);            
                    end
                end
            end
        end
    end
end

