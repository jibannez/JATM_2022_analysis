function M = get_pp_phisiological_at_ISA(ppdata, vnames, fcns, env)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 3, fcns = @nanmean; end
    if nargin < 4, env = 10; end
    
    EDAfs = 4;
    cnames = fieldnames(ppdata.ISA);
    isa_times = 2:2:16;    
    cno = length(cnames);
    vno = length(vnames);
    isano = length(isa_times);
    order = ppdata.order(2:2:12);
    M = nan(cno,isano,vno);
    for cn=1:cno
        cname = cnames{cn};
        trno = ismember(order,cname);
        for isan=1:isano
            t=isa_times(isan);
            for vn=2:vno
                vname = vnames{vn};                
                switch vname
                    case 'EDAtonic'
                        tidx_c = t * 60 * EDAfs;
                        envlocal = env * EDAfs;
                        data = ppdata.timeseries.EDA.trials_tonic{trno};
                        M(cn,isan,vn) = fcns(data(tidx_c-envlocal:tidx_c));
                    case  'EDAphasic'
                        tidx_c = t * 60 * EDAfs;
                        envlocal = env * EDAfs;                        
                        data = ppdata.timeseries.EDA.trials_phasic{trno};
                        M(cn,isan,vn) = fcns(data(tidx_c-envlocal:tidx_c));
                    case 'EDAtonicrel'
                        tidx_c = t * 60 * EDAfs;
                        envlocal = env * EDAfs;
                        globalmean = nanmean(ppdata.timeseries.EDA.global.tonic);
                        data = ppdata.timeseries.EDA.trials_tonic{trno}/globalmean;
                        M(cn,isan,vn) = fcns(data(tidx_c-envlocal:tidx_c));
                    case  'EDAphasicrel'
                        tidx_c = t * 60 * EDAfs;
                        envlocal = env * EDAfs;
                        globalmean = nanmean(ppdata.timeseries.EDA.global.phasic);
                        data = ppdata.timeseries.EDA.trials_phasic{trno}/globalmean;
                        M(cn,isan,vn) = fcns(data(tidx_c-envlocal:tidx_c));
                    case 'HR'
                        tidx_c = t * 60;
                        envlocal = env;   
                        data = ppdata.timeseries.HR.trials{trno};
                        M(cn,isan,vn) = fcns(data(tidx_c-envlocal:tidx_c));
                    case 'IBI'
                        data = fetch_IBI2_data(ppdata.timeseries.IBI2, trno, t, env);
                        M(cn,isan,vn) = nanmean(data);
                    case 'HRVSDSD'
                        data = fetch_IBI2_data(ppdata.timeseries.IBI2, trno, t, env);
                        M(cn,isan,vn) = HRV.SDSD(data);
                    case 'HRVSDNN'
                        data = fetch_IBI2_data(ppdata.timeseries.IBI2, trno, t, env);
                        M(cn,isan,vn) = HRV.SDNN(data);                        
                    case 'HRVRMSSD'
                        data = fetch_IBI2_data(ppdata.timeseries.IBI2, trno, t, env);
                        M(cn,isan,vn) = HRV.RMSSD(data);
                    case 'HRVpNN50'
                        data = fetch_IBI2_data(ppdata.timeseries.IBI2, trno, t, env);
                        M(cn,isan,vn) = HRV.pNN50(data);                        
                    case 'HRVTRI'
                        data = fetch_IBI2_data(ppdata.timeseries.IBI2, trno, t, env);
                        M(cn,isan,vn) = HRV.TRI(data);   
                    case 'HRVTINN'
                        data = fetch_IBI2_data(ppdata.timeseries.IBI2, trno, t, env);
                        M(cn,isan,vn) = HRV.TINN(data);                           
                    case 'HRVrr'
                        data = fetch_IBI2_data(ppdata.timeseries.IBI2, trno, t, env);
                        M(cn,isan,vn) = HRV.rrHRV(data);                           
                    otherwise
                        error(['Unknown variable in input: ' vname ])
                end
                
            end 
        end
    end       
end

function M = fetch_IBI2_data(IBI, ts_trial_number, t, env)
    data = IBI.trials{ts_trial_number};
    times = IBI.trial_times{ts_trial_number};
    idxs = times < (t + env) & times < (t - env);
    M = data(idxs);
end
