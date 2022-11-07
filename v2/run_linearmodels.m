function [lm,conf] = run_linearmodels(xp, dtype, fcn, env)
% Copyright 2022 Jorge Ibáñez Gijón.
    if nargin < 2, dtype = 'atisa'; end
    if nargin < 3, fcn = @nanmean; end
    if nargin < 4, env = 10; end
    
    import util.reshape_ndarray
    
    conf = prepare_conf(dtype,fcn, env);
    [M, conf] = getdata4correlations(xp, conf);

    if strcmp(dtype, 'pertrial')
        [ppno, cno, vno] = size(M);
        M2 = reshape_ndarray(M,[ppno*cno, vno]);
    else
        [ppno, cno, isano, vno] = size(M);
        M2 = reshape_ndarray(M,[ppno*cno*isano, vno]);
    end
    isaidx = ismember(conf.vnames,'ISA');
    ISA = M2(:,isaidx);
    COMETA_COMPONENTS = M2(:,~isaidx);
    conf.vnames'
    lm = fitlm(COMETA_COMPONENTS, ISA, 'linear')
end


function conf = prepare_conf(dtype,fcn, env)
    conf = check_conf(dtype); % creates default configuration, ready to edit
    conf.fcn_cometa = fcn;
    conf.env_cometa = env;
    conf.vnames_perf = {}; % removes performance variables
    conf.vnames_phys = {}; % removes phys variables
    conf.vnames_nasa = {}; % removes nasa variables
    conf.vnames_cometa = {'COMETAFlow', 'COMETAEvolution', 'COMETANonStandard', 'COMETAConflict', 'COMETAReduction'}; % removes cometa
    conf = check_conf(conf); % update vnames field
end
